# Storage

An implementation similar to `AppStorage` that also supports iOS 13, and can be used as a drop-in replacement.

- Identical API
- SwiftUI updates
- Fully documented
- Includes unit tests

In addition to an identical API, it adds support for other store types. By default, 2 stores are supported:

1. `DefaultsStorage`
2. `CloudStorage`

The first makes use of `UserDefaults` where the latter `NSUbiquitousKeyValueStore`.

## Usage

Since the API is identical to `AppStorage` it can be used as such:

```swift
@DefaultsStorage(wrappedValue: true, "isRegistered") var isRegistered
```

## SwiftUI

Similarly to `AppStorage` in iOS 14, the type supports `DynamicProperty` to allow automatic SwiftUI updates.

Meaning, if you update the value in `UserDefaults`, that value will be reflected in the underlying storage as well.
Resulting in the SwiftUI `View` automatically reload when a value changes, just as expected.

## Installation

Swift Package Manager is the recommended way to include this library, however given its a single file, you could equally just drag and `Storage.swift` file directly into your project.
