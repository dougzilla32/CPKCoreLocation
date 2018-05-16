import CoreLocation.CLLocationManager
import PromiseKit
#if !CPKCocoaPods
import CancelForPromiseKit
#endif

/**
 To import the `CLLocationManager` category:

    use_frameworks!
    pod "CancelForPromiseKit/CoreLocation"

 And then in your sources:

    import PromiseKit
    import CancelForPromiseKit
*/
extension CLLocationManager {
    /*
     /// The type of location permission we are asking for
     public enum RequestAuthorizationType {
         /// Determine the authorization from the application’s plist
         case automatic
         /// Request always-authorization
         case always
         /// Request when-in-use-authorization
         case whenInUse
     }
     */

    public enum PMKError: Error {
        case notAuthorized
    }
    /**
     Request the current location, with the ability to cancel the request.
     - Note: to obtain a single location use `Promise.lastValue`
     - Parameters:
       - authorizationType: requestAuthorizationType: We read your Info plist and try to
         determine the authorization type we should request automatically. If you
         want to force one or the other, change this parameter from its default
         value.
       - cancel: Optional cancel context, overrides the default context.
       - block: A block by which to perform any filtering of the locations that are
         returned. In order to only retrieve accurate locations, only return true if the
         locations horizontal accuracy < 50
     - Returns: A new promise that fulfills with the most recent CLLocation that satisfies
       the provided block if it exists. If the block does not exist, simply return the
       last location.
     */
    public class func requestLocationCC(authorizationType: RequestAuthorizationType = .automatic, cancel: CancelContext? = nil, satisfying block: ((CLLocation) -> Bool)? = nil) -> Promise<[CLLocation]> {
        
        let cancelContext = cancel ?? CancelContext()

        func std() -> Promise<[CLLocation]> {
            return LocationManager(cancel: cancelContext, satisfying: block).promise
        }

        func auth() -> Promise<Void> {
        #if os(macOS)
            return Promise(cancel: cancelContext) { seal in seal.fulfill(()) }
        #else
            func auth(type: PMKCLAuthorizationType) -> Promise<Void> {
                return AuthorizationCatcher(type: type, cancel: cancel).promise.doneCC(on: nil) {
                    switch $0 {
                    case .restricted, .denied:
                        throw PMKError.notAuthorized
                    default:
                        break
                    }
                }
            }

            switch authorizationType {
            case .automatic:
                switch Bundle.main.permissionType {
                case .always, .both:
                    return auth(type: .always)
                case .whenInUse:
                    return auth(type: .whenInUse)
                }
            case .whenInUse:
                return auth(type: .whenInUse)
            case .always:
                return auth(type: .always)
            }
        #endif
        }

        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            return std()
        case .notDetermined:
            return auth().thenCC(std)
        case .denied, .restricted:
            return Promise(error: PMKError.notAuthorized)
        }
    }

    @available(*, deprecated: 5.0, renamed: "requestLocation")
    public class func promiseCC(_ requestAuthorizationType: RequestAuthorizationType = .automatic, cancel: CancelContext? = nil, satisfying block: ((CLLocation) -> Bool)? = nil) -> Promise<[CLLocation]> {
        return requestLocationCC(authorizationType: requestAuthorizationType, cancel: cancel, satisfying: block)
    }
}

private class LocationManager: CLLocationManager, CLLocationManagerDelegate, CancellableTask {
    let (promise, seal) = Promise<[CLLocation]>.pending()
    let satisfyingBlock: ((CLLocation) -> Bool)?

    init(cancel: CancelContext, satisfying block: ((CLLocation) -> Bool)? = nil) {
        satisfyingBlock = block
        super.init()
        delegate = self
        
        promise.cancelContext = cancel
        cancel.append(task: self, reject: seal.reject)
        
    #if !os(tvOS)
        startUpdatingLocation()
    #else
        requestLocation()
    #endif
        _ = self.promise.ensure {
            self.stopUpdatingLocation()
        }
    }

    @objc fileprivate func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let block = satisfyingBlock {
            let satisfiedLocations = locations.filter(block)
            if !satisfiedLocations.isEmpty {
                seal.fulfill(satisfiedLocations)
            } else {
                #if os(tvOS)
                requestLocation()
                #endif
            }
        } else {
            seal.fulfill(locations)
        }
    }
    
    @objc func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let (domain, code) = { ($0.domain, $0.code) }(error as NSError)
        if code == CLError.locationUnknown.rawValue && domain == kCLErrorDomain {
            // Apple docs say you should just ignore this error
        } else {
            seal.reject(error)
        }
    }
    
    func cancel() {
        self.stopUpdatingLocation()
        isCancelled = true
    }
    
    var isCancelled = false
}


#if !os(macOS)

extension CLLocationManager {
    /**
      Request CoreLocation authorization from the user
      - Note: By default we try to determine the authorization type you want by inspecting your Info.plist
      - Note: This method will not perform upgrades from “when-in-use” to “always” unless you specify `.always` for the value of `type`.
     */
    @available(iOS 8, tvOS 9, watchOS 2, *)
    public class func requestAuthorization(type requestedAuthorizationType: RequestAuthorizationType = .automatic, cancel: CancelContext? = nil) -> Promise<CLAuthorizationStatus> {

        let currentStatus = CLLocationManager.authorizationStatus()

        func std(type: PMKCLAuthorizationType) -> Promise<CLAuthorizationStatus> {
            if currentStatus == .notDetermined {
                return AuthorizationCatcher(type: type, cancel: cancel).promise
            } else {
                return .valueCC(currentStatus, cancel: cancel)
            }
        }

        switch requestedAuthorizationType {
        case .always:
            func iOS11Check() -> Promise<CLAuthorizationStatus> {
                switch currentStatus {
                case .notDetermined, .authorizedWhenInUse:
                    return AuthorizationCatcher(type: .always, cancel: cancel).promise
                default:
                    return .valueCC(currentStatus, cancel: cancel)
                }
            }
        #if PMKiOS11
            // ^^ define PMKiOS11 if you deploy against the iOS 11 SDK
            // otherwise the warning you get below cannot be removed
            return iOS11Check()
        #else
            if #available(iOS 11, *) {
                return iOS11Check()
            } else {
                return std(type: .always)
            }
        #endif

        case .whenInUse:
            return std(type: .whenInUse)

        case .automatic:
            if currentStatus == .notDetermined {
                switch Bundle.main.permissionType {
                case .both, .whenInUse:
                    return AuthorizationCatcher(type: .whenInUse, cancel: cancel).promise
                case .always:
                    return AuthorizationCatcher(type: .always, cancel: cancel).promise
                }
            } else {
                return .valueCC(currentStatus, cancel: cancel)
            }
        }
    }
}

@available(iOS 8, *)
private class AuthorizationCatcher: CLLocationManager, CLLocationManagerDelegate, CancellableTask {
    let (promise, seal) = Promise<CLAuthorizationStatus>.pending()
    var retainCycle: AuthorizationCatcher?
    let initialAuthorizationState = CLLocationManager.authorizationStatus()

    init(type: PMKCLAuthorizationType, cancel: CancelContext) {
        super.init()

        promise.cancelContext = cancel
        cancel.append(task: self, reject: seal.reject)
        
        func ask(type: PMKCLAuthorizationType) {
            delegate = self
            retainCycle = self

            switch type {
            case .always:
            #if os(tvOS)
                fallthrough
            #else
                requestAlwaysAuthorization()
            #endif
            case .whenInUse:
                requestWhenInUseAuthorization()
            }

            _ = promise.done { _ in
                self.retainCycle = nil
            }
        }

        func iOS11Check() {
            switch (initialAuthorizationState, type) {
            case (.notDetermined, .always), (.authorizedWhenInUse, .always), (.notDetermined, .whenInUse):
                ask(type: type)
            default:
                seal.fulfill(initialAuthorizationState)
            }
        }

    #if PMKiOS11
        // ^^ define PMKiOS11 if you deploy against the iOS 11 SDK
        // otherwise the warning you get below cannot be removed
        iOS11Check()
    #else
        if #available(iOS 11, *) {
            iOS11Check()
        } else {
            if initialAuthorizationState == .notDetermined {
                ask(type: type)
            } else {
                seal.fulfill(initialAuthorizationState)
            }
        }
    #endif
    }

    @objc fileprivate func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // `didChange` is a lie; it fires this immediately with the current status.
        if status != initialAuthorizationState {
            seal.fulfill(status)
        }
    }
    
    func cancel() {
        self.retainCycle = nil
        isCancelled = true
    }
    
    var isCancelled = false
}

#endif

private extension Bundle {
    enum PermissionType {
        case both
        case always
        case whenInUse
    }

    var permissionType: PermissionType {
        func hasInfoPlistKey(_ key: String) -> Bool {
            let value = object(forInfoDictionaryKey: key) as? String ?? ""
            return !value.isEmpty
        }

        if hasInfoPlistKey("NSLocationAlwaysAndWhenInUseUsageDescription") {
            return .both
        }
        if hasInfoPlistKey("NSLocationAlwaysUsageDescription") {
            return .always
        }
        if hasInfoPlistKey("NSLocationWhenInUseUsageDescription") {
            return .whenInUse
        }

        if #available(iOS 11, *) {
            NSLog("PromiseKit: warning: `NSLocationAlwaysAndWhenInUseUsageDescription` key not set")
        } else {
            NSLog("PromiseKit: warning: `NSLocationWhenInUseUsageDescription` key not set")
        }

        // won't work, but we warned the user above at least
        return .whenInUse
    }
}

private enum PMKCLAuthorizationType {
    case always
    case whenInUse
}
