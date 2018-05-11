import CoreLocation.CLGeocoder
import PromiseKit
#if !CPKCocoaPods
import CancelForPromiseKit
#endif
#if os(iOS) || os(watchOS) || os(OSX)
import class Contacts.CNPostalAddress
#endif

/**
 To import the `CLGeocoder` category:

    use_frameworks!
    pod "CancelForPromiseKit/CoreLocation"

 And then in your sources:

    import PromiseKit
    import CancelForPromiseKit
*/
extension CLGeocoder {
    /// Submits a reverse-geocoding request for the specified location.
    public func reverseGeocode(location: CLLocation, cancel: CancelContext) -> Promise<[CLPlacemark]> {
        return Promise(cancel: cancel) { seal in
            self.reverseGeocodeLocation(location) { placemarks, error in
                seal.resolve(placemarks, error)
            }
        }
    }

    /// Submits a forward-geocoding request using the specified address dictionary.
    @available(iOS, deprecated: 11.0)
    public func geocode(_ addressDictionary: [String: String], cancel: CancelContext) -> Promise<[CLPlacemark]> {
        return Promise(cancel: cancel) { seal in
            self.geocodeAddressDictionary(addressDictionary, completionHandler: seal.resolve)
        }
    }

    /// Submits a forward-geocoding request using the specified address string.
    public func geocode(_ addressString: String, cancel: CancelContext) -> Promise<[CLPlacemark]> {
        return Promise(cancel: cancel) { seal in
            self.geocodeAddressString(addressString, completionHandler: seal.resolve)
        }
    }

    /// Submits a forward-geocoding request using the specified address string within the specified region.
    public func geocode(_ addressString: String, region: CLRegion?, cancel: CancelContext) -> Promise<[CLPlacemark]> {
        return Promise(cancel: cancel) { seal in
            self.geocodeAddressString(addressString, in: region, completionHandler: seal.resolve)
        }
    }

#if !os(tvOS) && swift(>=3.2)
    /// Submits a forward-geocoding request using the specified postal address.
    @available(iOS 11.0, OSX 10.13, watchOS 4.0, *)
    public func geocodePostalAddress(_ postalAddress: CNPostalAddress, cancel: CancelContext) -> Promise<[CLPlacemark]> {
        return Promise(cancel: cancel) { seal in
            self.geocodePostalAddress(postalAddress, completionHandler: seal.resolve)
        }
    }

    /// Submits a forward-geocoding requesting using the specified locale and postal address
    @available(iOS 11.0, OSX 10.13, watchOS 4.0, *)
    public func geocodePostalAddress(_ postalAddress: CNPostalAddress, preferredLocale locale: Locale?, cancel: CancelContext) -> Promise<[CLPlacemark]> {
        return Promise(cancel: cancel) { seal in
            self.geocodePostalAddress(postalAddress, preferredLocale: locale, completionHandler: seal.resolve)
        }
    }
#endif
 
}

// TODO still not possible in Swift 3.2
//extension CLError: CancellableError {
//    public var isCancelled: Bool {
//        return self == .geocodeCanceled
//    }
//}
