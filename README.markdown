# PromiseKit CoreLocation Extensions ![Build Status]

This project adds cancellable promises to [PromiseKit's CoreLocation extension].

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

[Build Status]: https://travis-ci.org/dougzilla32/CancelForPromiseKit-CoreLocation.svg?branch=master
[PromiseKit's CoreLocation extension]: https://github.com/PromiseKit/CoreLocation
