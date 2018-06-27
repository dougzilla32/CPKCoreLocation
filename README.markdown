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

To build with Carthage on versions of Swift prior to 4.1, set the 'Carthage' flag in your target's Build settings at the following location. This is necessary to properly import the PMKCoreLocation module, which is only defined for Carthage:
    
    TARGETS -> [Your target name]:
        'Swift Compiler - Custom Flags' -> 'Active Compilation Conditions' -> 'Debug'
        'Swift Compiler - Custom Flags' -> 'Active Compilation Conditions' -> 'Release'

[Build Status]: https://travis-ci.org/dougzilla32/CPKCoreLocation.svg?branch=master
[PromiseKit's CoreLocation extension]: https://github.com/PromiseKit/CoreLocation
