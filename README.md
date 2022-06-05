<p align="center">
  <img src="https://cdn.rawgit.com/omaralbeik/UserDefaultsStore/main/Assets/readme-logo.svg" title="UserDefaultsStore">
</p>

<p align="center">
  <a href="https://github.com/omaralbeik/UserDefaultsStore/actions"><img src="https://github.com/omaralbeik/UserDefaultsStore/workflows/UserDefaultsStore/badge.svg?branch=main" alt="Build Status"></a>
  <a href="https://codecov.io/gh/omaralbeik/UserDefaultsStore"><img src="https://codecov.io/gh/omaralbeik/UserDefaultsStore/branch/main/graph/badge.svg" alt="Test Coverage" /></a>
  <a href="https://swiftpackageindex.com/omaralbeik/UserDefaultsStore"><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fomaralbeik%2FUserDefaultsStore%2Fbadge%3Ftype%3Dswift-versions" alt="Swift versions" /></a>
  <a href="https://swiftpackageindex.com/omaralbeik/UserDefaultsStore"><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fomaralbeik%2FUserDefaultsStore%2Fbadge%3Ftype%3Dplatforms" alt="Platforms" /></a>
  <a href="https://github.com/omaralbeik/UserDefaultsStore/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-MIT-red.svg" alt="MIT"></a>
</p>

# tl;dr
You love Swift's `Codable` protocol and use it everywhere, who doesn't! Here is an easy and very light way to store and retrieve -**reasonable amount 😅**- of `Codable` objects, in a couple lines of code!

---

## New in v3.0

- Both `UserDefaultsStore` and `SingleUserDefaultsStore` are thread safe!
- **BREAKING**: Use of custom encoder/decoder has been removed.
- **BREAKING**: Snapshots have been removed.

---

## Installation

### Swift Package Manager

1. Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/omaralbeik/UserDefaultsStore.git", from: "3.0.0")
]
```

2. Build your project:

```sh
$ swift build
```

### Manually

Add the [Sources](https://github.com/omaralbeik/UserDefaultsStore/tree/main/Sources/UserDefaultsStore) folder to your Xcode project.

---

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


### 1. Conform to the `Identifiable` protocol and set the `id` property

The `Identifiable` protocol lets UserDefaultsStore knows what is the unique id for each object.

```swift
struct User: Codable, Identifiable {
    ...
}
```

```swift
struct Laptop: Codable, Identifiable {
    var id: String { model }
    ...
}
```

### 2. Create UserDefaults Stores

```swift
let usersStore = UserDefaultsStore<User>(uniqueIdentifier: "users")
let laptopsStore = UserDefaultsStore<Laptop>(uniqueIdentifier: "laptops")
```

### 3. Voilà, you're all set!

```swift
let macbook = Laptop(model: "A1278", name: "MacBook Pro")
let john = User(id: 1, firstName: "John", lastName: "Appleseed", laptop: macbook)

// Save an object to a store
try! usersStore.save(john)

// Save an array of objects to a store
try! usersStore.save([jane, steve, jessica])

// Get an object from store
let user = store.object(withId: 1)
let laptop = store.object(withId: "A1278")

// Get all objects in a store
let laptops = laptopsStore.allObjects()

// Check if store has an object
print(usersStore.hasObject(withId: 10)) // false

// Iterate over all objects in a store
laptopsStore.forEach { laptop in
    print(laptop.name)
}

// Delete an object from a store
usersStore.delete(withId: 1)

// Delete all objects in a store
laptops.deleteAll()

// Know how many objects are stored in a store
let usersCount = usersStore.objectsCount
```

## Looking to store a single item only?

Use [`SingleUserDefaultsStore`](https://github.com/omaralbeik/UserDefaultsStore/tree/main/Sources/UserDefaultsStore/SingleUserDefaultsStore.swift), it enables storing and retrieving a single value of `Int`, `Double`, `String`, or any `Codable` type.

## Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Swift 5.0+


## Thanks

Special thanks to:
- [Paul Hudson](https://twitter.com/twostraws) for his [article](https://www.hackingwithswift.com/articles/57/how-swift-keypaths-let-us-write-more-natural-code) on how to use Swift keypaths to write more natural code.
- [Batuhan Saka](https://github.com/strawb3rryx7) for helping with translation into Turkish

## Credits

Icon made by [freepik](https://www.flaticon.com/authors/freepik) from [flaticon.com](https://www.flaticon.com).


## License

UserDefaultsStore is released under the MIT license. See [LICENSE](https://github.com/omaralbeik/UserDefaultsStore/blob/main/LICENSE) for more information.
