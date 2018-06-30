# UserDefaultsStore

[![Build Status](https://api.travis-ci.org/omaralbeik/UserDefaultsStore.svg?branch=master)](https://travis-ci.org/omaralbeik/UserDefaultsStore)
[![Platforms](https://img.shields.io/cocoapods/p/UserDefaultsStore.svg?style=flat)](https://github.com/omaralbeik/UserDefaultsStore)
[![Cocoapods](https://img.shields.io/cocoapods/v/UserDefaultsStore.svg)](https://cocoapods.org/pods/UserDefaultsStore)
[![codecov](https://codecov.io/gh/omaralbeik/UserDefaultsStore/branch/master/graph/badge.svg)](https://codecov.io/gh/omaralbeik/UserDefaultsStore)
[![Swift](https://img.shields.io/badge/Swift-4.1-orange.svg)](https://swift.org)
[![Xcode](https://img.shields.io/badge/Xcode-9.4-blue.svg)](https://developer.apple.com/xcode)
[![MIT](https://img.shields.io/badge/License-MIT-red.svg)](https://opensource.org/licenses/MIT)


# tl;dr
You love Swift's `Codable` protocol and use it everywhere, here is an easy and very light way to store - reasonable amount 😅 - of Codable objects, in a couple lines of code


## Installation

#### CocoaPods
To integrate UserDefaultsStore into your iOS project using [CocoaPods](https://cocoapods.org/), specify it in your Podfile:
```ruby
pod 'UserDefaultsStore'
```

#### Manually
Add the [Sources](Sources/) folder to your Xcode project.


## Usage

Let's say you have 2 structs; `User` and `Laptop` defined as bellow:
```swift
struct User: Codable {
    var id: Int
    var firstName: String
    var lastName: String
    var laptop: Laptop?
}
```

```swift
struct Laptop: Codable {
    var model: String
    var name: String
}
```

Here is how you store them in **UserDefaultsStore**:


### 1. Conform to the `Identifiable` protocol and set the `idKey` property
The `Identifiable` protocol lets UserDefaultsStore knows what is the unique id for each object.

```swift
struct User: Codable, Identifiable {
    static let idKey = \User.id
    ...
}
```

```swift
struct Laptop: Codable, Identifiable {
    static let idKey = \Laptop.model
    ...
}
```

* Notice how `User` uses `Int` for its id, while `Laptop` uses `String`!

### 2. Create UserDefaults Store
```swift
let usersStore = UserDefaultsStore<User>(uniqueIdentifier: "users")!
let laptopsStore = UserDefaultsStore<Laptop>(uniqueIdentifier: "laptops")!
```

### 3. Voilà, you're all set
```swift
let macbook = Laptop(model: "A1278", name: "MacBook Pro")
let john = User(userId: 1, firstName: "John", lastName: "Appleseed", laptop: macbook)

// Save an object to a store
try! usersStore.set(john)

// Get an object from store
let user = try! store.get(id: 1)

// Get all objects in a store
let laptops = try! laptopsStore.getAll()

// Delete an object from a store
usersStore.delete(id: 1)

// Delete all objects in a store
laptops.deleteAll()

// Know how many objects are stored in a store
let usersCount = usersStore.objectsCount

```


## Requirements
- iOS 8.0+ / macOS 10.12+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 9+
- Swift 4+


## Thanks
Special thanks to [Paul Hudson](https://twitter.com/twostraws) for his [article](https://www.hackingwithswift.com/articles/57/how-swift-keypaths-let-us-write-more-natural-code) on how to use Swift keypaths.


## License
UserDefaultsStore is released under the MIT license. See [LICENSE](LICENSE) for more information.
