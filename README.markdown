# CancelForPromiseKit CoreLocation Extensions

[![badge-docs](https://dougzilla32.github.io/CPKCoreLocation/api/badge.svg)](https://dougzilla32.github.io/CPKCoreLocation/api/) [![Build Status](https://travis-ci.org/dougzilla32/CPKCoreLocation.svg?branch=master)](https://travis-ci.org/dougzilla32/CPKCoreLocation)

This project adds cancellable promises to [PromiseKit's CoreLocation extension].

Here is the [Jazzy](https://github.com/realm/jazzy) generated [CancelForPromiseKit CoreLocation Extensions API documentation](https://dougzilla32.github.io/CPKCoreLocation/api/).

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

[PromiseKit's CoreLocation extension]: https://github.com/PromiseKit/CoreLocation
