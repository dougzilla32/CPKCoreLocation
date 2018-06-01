# PromiseKit CoreLocation Extensions ![Build Status]

This project adds promises to Apple’s CoreLocation framework.

## CocoaPods

```ruby
pod "PromiseKit/CoreLocation", "~> 6.0"
pod "CancelForPromiseKit/CoreLocation", "~> 1.0"
```

The extensions are built into `PromiseKit.framework` thus nothing else is needed.

## Carthage

```ruby
github "PromiseKit/CoreLocation" ~> 3.0
github "CancelForPromiseKit/CoreLocation" ~> 1.0
```

The extensions are built into their own framework:

```swift
// swift
import PromiseKit
import CancelForPromiseKit
import CPKCoreLocation
```

[Build Status]: https://travis-ci.org/CancelForPromiseKit/CoreLocation.svg?branch=master
