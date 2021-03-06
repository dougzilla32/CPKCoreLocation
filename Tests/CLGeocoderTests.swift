import CPKCoreLocation
import CoreLocation
import PromiseKit
import CancelForPromiseKit
import XCTest
#if os(iOS) || os(watchOS) || os(OSX)
import class Contacts.CNPostalAddress
#endif

class CLGeocoderTests: XCTestCase {
    func testCancel_reverseGeocodeLocation() {
        class MockGeocoder: CLGeocoder {
            override func reverseGeocodeLocation(_ location: CLLocation, completionHandler: @escaping CLGeocodeCompletionHandler) {
                after(.milliseconds(100)).done {
                    completionHandler([dummyPlacemark], nil)
                }
            }
        }

        let ex = expectation(description: "")
        MockGeocoder().reverseGeocodeCC(location: CLLocation()).done { _ in
            XCTFail("not cancelled")
        }.catch(policy: .allErrors) { error in
            error.isCancelled ? ex.fulfill() : XCTFail("error \(error)")
        }.cancel()
        
        waitForExpectations(timeout: 1)
    }

    func testCancel_geocodeAddressDictionary() {
        class MockGeocoder: CLGeocoder {
            override func geocodeAddressDictionary(_ addressDictionary: [AnyHashable: Any], completionHandler: @escaping CLGeocodeCompletionHandler) {
                after(.milliseconds(100)).done {
                    completionHandler([dummyPlacemark], nil)
                }
            }
        }

        let ex = expectation(description: "")
        let context = MockGeocoder().geocodeCC([:]).done { _ in
            XCTFail("not cancelled")
        }.catch(policy: .allErrors) { error in
            error.isCancelled ? ex.fulfill() : XCTFail("error \(error)")
        }.cancelContext
        after(.milliseconds(50)).done {
            context.cancel()
        }
        
        waitForExpectations(timeout: 1)
    }

    func testCancel_geocodeAddressString() {
        class MockGeocoder: CLGeocoder {
            override func geocodeAddressString(_ addressString: String, completionHandler: @escaping CLGeocodeCompletionHandler) {
                after(.milliseconds(100)).done {
                    completionHandler([dummyPlacemark], nil)
                }
            }
        }

        let ex = expectation(description: "")
        let p = MockGeocoder().geocodeCC("").done { _ in
            XCTFail("not cancelled")
        }.catch(policy: .allErrors) { error in
            error.isCancelled ? ex.fulfill() : XCTFail("error \(error)")
        }
        after(.milliseconds(50)).done {
            p.cancel()
        }
        waitForExpectations(timeout: 1)
    }

#if !os(tvOS) && swift(>=3.2)
    func testCancel_geocodePostalAddress() {
        guard #available(iOS 11.0, OSX 10.13, watchOS 4.0, *) else { return }

        class MockGeocoder: CLGeocoder {
            override func geocodePostalAddress(_ postalAddress: CNPostalAddress, completionHandler: @escaping CLGeocodeCompletionHandler) {
                after(.milliseconds(100)).done {
                    completionHandler([dummyPlacemark], nil)
                }
            }
        }

        let ex = expectation(description: "")
        let p = MockGeocoder().geocodePostalAddressCC(CNPostalAddress()).done { _ in
            XCTFail("not cancelled")
        }.catch(policy: .allErrors) { error in
            error.isCancelled ? ex.fulfill() : XCTFail("error \(error)")
        }
        after(.milliseconds(50)).done {
            p.cancel()
        }
        waitForExpectations(timeout: 1)
    }

    func testCancel_geocodePostalAddressLocale() {
        guard #available(iOS 11.0, OSX 10.13, watchOS 4.0, *) else { return }

        class MockGeocoder: CLGeocoder {
            override func geocodePostalAddress(_ postalAddress: CNPostalAddress, preferredLocale locale: Locale?, completionHandler: @escaping CLGeocodeCompletionHandler) {
                after(.milliseconds(100)).done {
                    completionHandler([dummyPlacemark], nil)
                }
            }
        }

        let ex = expectation(description: "")
        let p = MockGeocoder().geocodePostalAddressCC(CNPostalAddress(), preferredLocale: nil).done { _ in
            XCTFail("not cancelled")
        }.catch(policy: .allErrors) { error in
            error.isCancelled ? ex.fulfill() : XCTFail("error \(error)")
        }
        after(.milliseconds(50)).done {
            p.cancel()
        }
        waitForExpectations(timeout: 1)
    }
#endif
}

private let dummyPlacemark = CLPlacemark()
