<p align="center">
  <img src="https://cdn.rawgit.com/omaralbeik/UserDefaultsStore/master/Assets/readme-logo.svg" title="UserDefaultsStore">
</p>

<p align="center">
  <a href="https://travis-ci.org/omaralbeik/UserDefaultsStore"><img src="https://travis-ci.org/omaralbeik/UserDefaultsStore.svg?branch=master" alt="Build Status"></a>
  <a href="https://codecov.io/gh/omaralbeik/UserDefaultsStore"><img src="https://codecov.io/gh/omaralbeik/UserDefaultsStore/branch/master/graph/badge.svg" alt="Test Coverage" /></a>
  <a href="https://codebeat.co/projects/github-com-omaralbeik-userdefaultsstore-master"><img alt="codebeat badge" src="https://codebeat.co/badges/e12405dc-1370-49bb-bd35-5f248a347f1a" /></a>
  <a href="https://github.com/omaralbeik/UserDefaultsStore"><img src="https://img.shields.io/cocoapods/p/UserDefaultsStore.svg?style=flat" alt="Platforms" /></a>
  <a href="https://cocoapods.org/pods/UserDefaultsStore"><img src="https://img.shields.io/cocoapods/v/UserDefaultsStore.svg" alt="Cocoapods" /></a>
  <a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage compatible" /></a>
  <a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat" alt="Swift Package Manager compatible" /></a>
  <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-4.2-orange.svg" alt="Swift" /></a>
  <a href="https://developer.apple.com/xcode"><img src="https://img.shields.io/badge/Xcode-10-blue.svg" alt="Xcode"></a>
  <a href="https://github.com/omaralbeik/UserDefaultsStore/blob/master/LICENSE"><img src="https://img.shields.io/badge/License-MIT-red.svg" alt="MIT"></a>
</p>

> A Turkish version of this document can be found [here](https://github.com/omaralbeik/UserDefaultsStore/blob/master/README_TR.md).

# tl;dr
You love Swift's `Codable` protocol and use it everywhere, who doesn't! Here is an easy and very light way to store and retrieve -**reasonable amount 😅**- of `Codable` objects, in a couple lines of code!


## Installation

<details>
<summary>CocoaPods (Recommended)</summary>
</br>
<p>To integrate UserDefaultsStore into your Xcode project using <a href="http://cocoapods.org">CocoaPods</a>, specify it in your <code>Podfile</code>:</p>
<pre><code class="ruby language-ruby">pod 'UserDefaultsStore'</code></pre>
</details>

<details>
<summary>Carthage</summary>
</br>
<p>To integrate UserDefaultsStore into your Xcode project using <a href="https://github.com/Carthage/Carthage">Carthage</a>, specify it in your <code>Cartfile</code>:</p>

<pre><code class="ogdl language-ogdl">github "omaralbeik/UserDefaultsStore" ~&gt; 1.0
</code></pre>
</details>

<details>
<summary>Swift Package Manager</summary>
</br>
<p>The <a href="https://swift.org/package-manager/">Swift Package Manager</a> is a tool for automating the distribution of Swift code and is integrated into the swift compiler. It is in early development, but UserDefaultsStore does support its use on supported platforms.</p>
<p>Once you have your Swift package set up, adding UserDefaultsStore as a dependency is as easy as adding it to the dependencies value of your Package.swift.</p>

<pre><code class="swift language-swift">import PackageDescription
dependencies: [
    .package(url: "https://github.com/omaralbeik/UserDefaultsStore.git", from: "1.0.2")
]
</code></pre>
</details>

<details>
<summary>Manually</summary>
</br>
<p>Add the <a href="https://github.com/omaralbeik/UserDefaultsStore/tree/master/Sources">Sources</a> folder to your Xcode project.</p>
</details>


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

> Notice how `User` uses `Int` for its id, while `Laptop` uses `String`, in fact the id can be any `Hashable` type. UserDefaults uses Swift keypaths to refer to properties without actually invoking them. Swift rocks 🤘


### 2. Create UserDefaults Stores

```swift
let usersStore = UserDefaultsStore<User>(uniqueIdentifier: "users")!
let laptopsStore = UserDefaultsStore<Laptop>(uniqueIdentifier: "laptops")!
```

### 3. Voilà, you're all set!

```swift
let macbook = Laptop(model: "A1278", name: "MacBook Pro")
let john = User(userId: 1, firstName: "John", lastName: "Appleseed", laptop: macbook)

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

Use [`SingleUserDefaultsStore`](https://github.com/omaralbeik/UserDefaultsStore/blob/master/Sources/SingleUserDefaultsStore.swift), it enables storing and retrieving a single value of `Int`, `Double`, `String`, or any `Codable` type.


## Requirements

- iOS 8.0+ / macOS 10.10+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 10.0+
- Swift 4.2+


## Thanks

Special thanks to:
- [Paul Hudson](https://twitter.com/twostraws) for his [article](https://www.hackingwithswift.com/articles/57/how-swift-keypaths-let-us-write-more-natural-code) on how to use Swift keypaths to write more natural code.
- [Batuhan Saka](https://github.com/strawb3rryx7) for translating this document into [Turkish](https://github.com/omaralbeik/UserDefaultsStore/blob/master/README_TR.md).

## Credits

Icon made by [freepik](https://www.flaticon.com/authors/freepik) from [flaticon.com](https://www.flaticon.com).


## License

UserDefaultsStore is released under the MIT license. See [LICENSE](https://github.com/omaralbeik/UserDefaultsStore/blob/master/LICENSE) for more information.
