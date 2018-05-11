import CPKCoreLocation
import CoreLocation
import PromiseKit
import CancelForPromiseKit
import XCTest
#if os(iOS) || os(watchOS) || os(OSX)
    import class Contacts.CNPostalAddress
#endif

class CLGeocoderTests: XCTestCase {
    func test_reverseGeocodeLocation() {
        class MockGeocoder: CLGeocoder {
            override func reverseGeocodeLocation(_ location: CLLocation, completionHandler: @escaping CLGeocodeCompletionHandler) {
                after(.milliseconds(100)).done {
                    completionHandler([dummyPlacemark], nil)
                }
            }
        }

        let context = CancelContext()
        let ex = expectation(description: "")
        MockGeocoder().reverseGeocode(location: CLLocation(), cancel: context).doneCC { x in
            XCTFail("not cancelled")
        }.catch(policy: .allErrors) { error in
            error.isCancelled ? ex.fulfill() : XCTFail("error \(error)")
        }
        context.cancel()
        
        waitForExpectations(timeout: 1)
    }

    func test_geocodeAddressDictionary() {
        class MockGeocoder: CLGeocoder {
            override func geocodeAddressDictionary(_ addressDictionary: [AnyHashable : Any], completionHandler: @escaping CLGeocodeCompletionHandler) {
                after(.milliseconds(100)).done {
                    completionHandler([dummyPlacemark], nil)
                }
            }
        }

        let context = CancelContext()
        let ex = expectation(description: "")
        MockGeocoder().geocode([:], cancel: context).doneCC { x in
            XCTFail("not cancelled")
        }.catch(policy: .allErrors) { error in
            error.isCancelled ? ex.fulfill() : XCTFail("error \(error)")
        }
        after(.milliseconds(50)).done {
            context.cancel()
        }
        
        waitForExpectations(timeout: 1)
    }

    func test_geocodeAddressString() {
        class MockGeocoder: CLGeocoder {
            override func geocodeAddressString(_ addressString: String, completionHandler: @escaping CLGeocodeCompletionHandler) {
                after(.milliseconds(100)).done {
                    completionHandler([dummyPlacemark], nil)
                }
            }
        }

        let context = CancelContext()
        let ex = expectation(description: "")
        MockGeocoder().geocode("", cancel: context).doneCC { x in
            XCTFail("not cancelled")
        }.catch(policy: .allErrors) { error in
            error.isCancelled ? ex.fulfill() : XCTFail("error \(error)")
        }
        after(.milliseconds(50)).done {
            context.cancel()
        }
        waitForExpectations(timeout: 1)
    }

#if !os(tvOS) && swift(>=3.2)
    func test_geocodePostalAddress() {
        guard #available(iOS 11.0, OSX 10.13, watchOS 4.0, *) else { return }

        class MockGeocoder: CLGeocoder {
            override func geocodePostalAddress(_ postalAddress: CNPostalAddress, completionHandler: @escaping CLGeocodeCompletionHandler) {
                after(.milliseconds(100)).done {
                    completionHandler([dummyPlacemark], nil)
                }
            }
        }

        let context = CancelContext()
        let ex = expectation(description: "")
        MockGeocoder().geocodePostalAddress(CNPostalAddress(), cancel: context).doneCC { x in
            XCTFail("not cancelled")
        }.catch(policy: .allErrors) { error in
            error.isCancelled ? ex.fulfill() : XCTFail("error \(error)")
        }
        after(.milliseconds(50)).done {
            context.cancel()
        }
        waitForExpectations(timeout: 1)
    }

    func test_geocodePostalAddressLocale() {
        guard #available(iOS 11.0, OSX 10.13, watchOS 4.0, *) else { return }

        class MockGeocoder: CLGeocoder {
            override func geocodePostalAddress(_ postalAddress: CNPostalAddress, preferredLocale locale: Locale?, completionHandler: @escaping CLGeocodeCompletionHandler) {
                after(.milliseconds(100)).done {
                    completionHandler([dummyPlacemark], nil)
                }
            }
        }

        let context = CancelContext()
        let ex = expectation(description: "")
        MockGeocoder().geocodePostalAddress(CNPostalAddress(), preferredLocale: nil, cancel: context).doneCC { x in
            XCTFail("not cancelled")
        }.catch(policy: .allErrors) { error in
            error.isCancelled ? ex.fulfill() : XCTFail("error \(error)")
        }
        after(.milliseconds(50)).done {
            context.cancel()
        }
        waitForExpectations(timeout: 1)
    }
#endif
}

private let dummyPlacemark = CLPlacemark()
