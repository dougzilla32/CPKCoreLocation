import CPKCoreLocation
import CoreLocation
import PromiseKit
import CancelForPromiseKit
import XCTest

#if !os(tvOS)

class Test_CLLocationManager_Swift: XCTestCase {
    func testCancel_fulfills_with_multiple_locations() {
        swizzle(CLLocationManager.self, #selector(CLLocationManager.startUpdatingLocation)) {
            swizzle(CLLocationManager.self, #selector(CLLocationManager.authorizationStatus), isClassMethod: true) {
                let ex = expectation(description: "")

                let p = CLLocationManager.requestLocationCC().done { _ in
                    XCTFail("not cancelled")
                }.catch(policy: .allErrors) { error in
                    error.isCancelled ? ex.fulfill() : XCTFail("error \(error)")
                }
                after(.milliseconds(50)).done {
                    p.cancel()
                }

                waitForExpectations(timeout: 1)
            }
        }
    }

    func testCancel_fufillsWithSatisfyingBlock() {
        swizzle(CLLocationManager.self, #selector(CLLocationManager.startUpdatingLocation)) {
            swizzle(CLLocationManager.self, #selector(CLLocationManager.authorizationStatus), isClassMethod: true) {
                let ex = expectation(description: "")
                let block: ((CLLocation) -> Bool) = { location in
                    return location.coordinate.latitude == dummy.last?.coordinate.latitude
                }
                let p = CLLocationManager.requestLocationCC(satisfying: block).done { _ in
                    XCTFail("not cancelled")
                }.catch(policy: .allErrors) { error in
                    error.isCancelled ? ex.fulfill() : XCTFail("error \(error)")
                }
                after(.milliseconds(50)).done {
                    p.cancel()
                }
                waitForExpectations(timeout: 1)
            }
        }
    }

#if os(iOS)
    func testCancel_requestAuthorization() {
        let ex = expectation(description: "")

        let p = CLLocationManager.requestAuthorizationCC().done { _ in
            XCTFail("not cancelled")
        }.catch(policy: .allErrors) { error in
            error.isCancelled ? ex.fulfill() : XCTFail("error \(error)")
        }
        p.cancel()

        waitForExpectations(timeout: 1, handler: nil)
    }
#endif
}

/////////////////////////////////////////////////////////////// resources
private let dummy = [CLLocation(latitude: 0, longitude: 0), CLLocation(latitude: 10, longitude: 20)]

extension CLLocationManager {
    @objc func pmk_startUpdatingLocation() {
        after(.milliseconds(100)).done {
            self.delegate!.locationManager?(self, didUpdateLocations: dummy)
        }
    }

    @objc static func pmk_authorizationStatus() -> CLAuthorizationStatus {
    #if os(macOS)
        return .authorized
    #else
        return .authorizedWhenInUse
    #endif
    }
}

/////////////////////////////////////////////////////////////// utilities
import ObjectiveC

func swizzle(_ foo: AnyClass, _ from: Selector, isClassMethod: Bool = false, body: () -> Void) {
    let originalMethod: Method
    let swizzledMethod: Method

    if isClassMethod {
        originalMethod = class_getClassMethod(foo, from)!
        swizzledMethod = class_getClassMethod(foo, Selector("pmk_\(from)"))!
    } else {
        originalMethod = class_getInstanceMethod(foo, from)!
        swizzledMethod = class_getInstanceMethod(foo, Selector("pmk_\(from)"))!
    }

    method_exchangeImplementations(originalMethod, swizzledMethod)
    body()
    method_exchangeImplementations(swizzledMethod, originalMethod)
}

#endif
