<p align="center">
  <img src="https://cdn.rawgit.com/omaralbeik/UserDefaultsStore/master/Assets/readme-logo.svg" title="UserDefaultsStore">
</p>

<p align="center">
  <a href="https://github.com/omaralbeik/UserDefaultsStore/actions"><img src="https://github.com/omaralbeik/UserDefaultsStore/workflows/UserDefaultsStore/badge.svg?branch=master" alt="Build Status"></a>
  <a href="https://codecov.io/gh/omaralbeik/UserDefaultsStore"><img src="https://codecov.io/gh/omaralbeik/UserDefaultsStore/branch/master/graph/badge.svg" alt="Test Coverage" /></a>
  <a href="https://github.com/omaralbeik/UserDefaultsStore"><img src="https://img.shields.io/cocoapods/p/UserDefaultsStore.svg?style=flat" alt="Platforms" /></a>
  <a href="https://cocoapods.org/pods/UserDefaultsStore"><img src="https://img.shields.io/cocoapods/v/UserDefaultsStore.svg" alt="Cocoapods" /></a>
  <a href="https://github.com/Carthage/Carthage"><img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat" alt="Carthage compatible" /></a>
  <a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat" alt="Swift Package Manager compatible" /></a>
  <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-4.2-orange.svg" alt="Swift" /></a>
  <a href="https://developer.apple.com/xcode"><img src="https://img.shields.io/badge/Xcode-10-blue.svg" alt="Xcode"></a>
  <a href="https://github.com/omaralbeik/UserDefaultsStore/blob/master/LICENSE"><img src="https://img.shields.io/badge/License-MIT-red.svg" alt="MIT"></a>
</p>


# tl;dr

Swift'in `Codable` protokolüne bayılıyorsun ve her yerde kullanıyorsun, kim kullanmadı ki! İşte `Codable` objelerini saklamak ve istediğiniz zaman geri almak için kolay ve hafif bir yol!


## Kurulum

<details>
<summary>CocoaPods (Tavsiye Edilen)</summary>
</br>


<p>UserDefaultsStore'u <a href="http://cocoapods.org">CocoaPods</a>'u kullanarak Xcode projenize entegre etmek için, bunu <code>Podfile</code>'da belirtin:

<pre><code class="ruby language-ruby">pod 'UserDefaultsStore'</code></pre>
</details>

<details>
<summary>Carthage</summary>
</br>
<p>UserDefaultsStore'u <a href="https://github.com/Carthage/Carthage">Carthage</a>'u kullanarak Xcode projenize entegre etmek için, bunu <code>Cartfile</code>'da belirtin:

<pre><code class="ogdl language-ogdl">github "omaralbeik/UserDefaultsStore" ~&gt; 1.5.0
</code></pre>
</details>

<details>
<summary>Swift Package Manager</summary>
</br>

<p><a href="https://swift.org/package-manager/">Swift Package Manager</a>, Swift kodunun dağıtımını otomatikleştirmek için bir araçtır ve hızlı derleyiciye entegre edilmiştir. Erken gelişim aşamasındadır, ancak UserDefaultsStore desteklenen platformlarda kullanımını desteklemektedir. </p>

<p>Swift paketinizi kurduktan sonra, UserDefaultsStore'u bağımlı olarak eklemek, Package.swift'inizin bağımlılık değerine eklemek kadar kolaydır.</p>

<pre><code class="swift language-swift">import PackageDescription
dependencies: [
    .package(url: "https://github.com/omaralbeik/UserDefaultsStore.git", from: "1.5.0")
]
</code></pre>
</details>

<details>
<summary>Manuel</summary>
</br>

<p><a href="https://github.com/omaralbeik/UserDefaultsStore/tree/master/Sources">Sources</a> klasörünü Xcode projenize ekleyin.</p>
</details>


## Kullanım

`User` ve `Laptop` olmak üzere aşağıda tanımlamış 2 adet struct'a sahipsiniz.

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

Bunları **UserDefaultsStore**'da nasıl saklayabileceğinizi göreceksiniz:


### 1.  `Identifiable` protokolüne uygun ve `idKey` özelliği ayarlanmalıdır.
`Identifiable` protokolü, UserDefaultsStore'un her nesne için neyin benzersiz bir kimlik olduğunu bilmesini sağlar.

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

* `User` kendi benzersiz kimliği için `Int` türünü kullanırken, `Laptop`'un `String` türünü kullandığını farkedin. Swift rocks 🤘

### 2. UserDefaults Depoları Oluştur
```swift
let usersStore = UserDefaultsStore<User>(uniqueIdentifier: "users")!
let laptopsStore = UserDefaultsStore<Laptop>(uniqueIdentifier: "laptops")!
```

### 3. Voilà, hazırsın!
```swift
let macbook = Laptop(model: "A1278", name: "MacBook Pro")
let john = User(userId: 1, firstName: "John", lastName: "Appleseed", laptop: macbook)

// Depo'da tek bir nesne saklamanıza imkan verir
try! usersStore.save(john)

// Depo'da bir dizi saklamanıza imkan verir
try! usersStore.save([jane, steve, jessica])

// Depo'dan tek bir nesne getirir
let user = store.object(withId: 1)

// Depo'daki tüm nesneleri getirir
let laptops = laptopsStore.allObjects()

// Depo içerisinde belirtilen tanımlayıcının varolup olmadığını sorgulayar
print(usersStore.hasObject(withId: 10)) // false

// Depo içerisindeki tüm nesneleri yineler
laptopsStore.forEach { laptop in
    print(laptop.name)
}

// Depo'dan bir nesne siler
usersStore.delete(withId: 1)

// Depo'daki tüm nesneleri siler
laptops.deleteAll()

// Depo'da kaç nesnenin saklandığını dönderir
let usersCount = usersStore.objectsCount

```


##
[`SingleUserDefaultsStore`](https://github.com/omaralbeik/UserDefaultsStore/blob/master/Sources/SingleUserDefaultsStore.swift)'ı kullanarak tek bir nesneyi saklayabilirsiniz. Token ve giriş yapmış kullanıcı verisi gibi, ...


## Gereksinimler
- iOS 8.0+ / macOS 10.10+ / tvOS 9.0+ / watchOS 2.0+
- Xcode 10.0+
- Swift 4.2+


## Teşekkürler
Swift Keypath'leri kullanarak daha doğal kod nasıl yazılır sorusuna cevap verdiği [makelesi](https://www.hackingwithswift.com/articles/57/how-swift-keypaths-let-us-write-more-natural-code) için [Paul Hudson](https://twitter.com/twostraws)'a çok teşekkürler.


## Katkıda Bulunanlar
[flaticon.com](https://www.flaticon.com)'dan [freepik](https://www.flaticon.com/authors/freepik) simgeyi hazırladı.


## Lisans
UserDefaultsStore MIT lisansı altında yayınlandı. Daha fazlası için [LICENSE](https://github.com/omaralbeik/UserDefaultsStore/blob/master/LICENSE) dosyasına bakabilirsiniz.
