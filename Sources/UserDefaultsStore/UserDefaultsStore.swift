//
//  UserDefaultsStore
//
//  Copyright (c) 2018-Present Omar Albeik - https://github.com/omaralbeik
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation

/// `UserDefaultsStore` offers a convenient way to store a collection of `Codable` objects in `UserDefaults`.
/// It is safe to use the store in multiple threads.
open class UserDefaultsStore<Object: Codable & Identifiable> {

  private let store: UserDefaults
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  private let lock = NSRecursiveLock()

  private func sync(action: () throws -> Void) rethrows {
    lock.lock()
    try action()
    lock.unlock()
  }

  /// Store's unique identifier.
  ///
  /// **Warning**: Never use the same identifier for two -or more- different stores.
  public let uniqueIdentifier: String

  /// Initialize store with given identifier.
  ///
  /// **Warning**: Never use the same identifier for two -or more- different stores.
  ///
  /// - Parameter uniqueIdentifier: store's unique identifier.
  required public init(uniqueIdentifier: String) {
    guard let store = UserDefaults(suiteName: uniqueIdentifier) else {
      preconditionFailure("Can not create a store with identifier: '\(uniqueIdentifier)'.")
    }
    self.uniqueIdentifier = uniqueIdentifier
    self.store = store
  }

  /// Save object to store. _O(1)_
  ///
  /// - Parameter object: object to save.
  /// - Throws: JSON encoding error.
  public func save(_ object: Object) throws {
    try sync {
      let data = try encoder.encode(object)
      let key = key(for: object)
      if store.object(forKey: key) == nil {
        increaseCounter()
      }
      store.set(data, forKey: key)
    }
  }

  /// Save optional object (if not nil) to store. _O(1)_
  ///
  /// - Parameter optionalObject: optional object to save.
  /// - Throws: JSON encoding error.
  public func save(_ optionalObject: Object?) throws {
    try sync {
      guard let object = optionalObject else { return }
      try save(object)
    }
  }

  /// Save array of m objects to store. _O(m)_
  ///
  /// - Parameter objects: object to save.
  /// - Throws: JSON encoding error.
  public func save(_ objects: [Object]) throws {
    try sync {
      let pairs = try objects.map({ (key: key(for: $0), data: try encoder.encode($0)) })
      pairs.forEach { pair in
        if store.object(forKey: pair.key) == nil {
          increaseCounter()
        }
        store.set(pair.data, forKey: pair.key)
      }
    }
  }

  /// Get object from store by its id. _O(1)_
  ///
  /// - Parameter id: object id.
  /// - Returns: optional object.
  public func object(withId id: Object.ID) -> Object? {
    guard let data = store.data(forKey: key(for: id)) else { return nil }
    return try? decoder.decode(Object.self, from: data)
  }

  /// Get array of objects from store for array of m id values. _O(m)_
  ///
  /// - Parameter ids: array of ids.
  /// - Returns: array of objects with the given ids.
  public func objects(withIds ids: [Object.ID]) -> [Object] {
    return ids.compactMap { object(withId: $0) }
  }

  /// Get all objects from store. _O(n)_
  ///
  /// - Returns: array of all objects in store.
  public func allObjects() -> [Object] {
    guard objectsCount > 0 else { return [] }

    return store.dictionaryRepresentation().keys.compactMap { key -> Object? in
      guard isObjectKey(key) else { return nil }
      guard let data = store.data(forKey: key) else { return nil }
      return try? decoder.decode(Object.self, from: data)
    }
  }

  /// Delete object by its id from store. _O(1)_
  ///
  /// - Parameter id: object id.
  public func delete(withId id: Object.ID) {
    sync {
      guard hasObject(withId: id) else { return }
      store.removeObject(forKey: key(for: id))
      decreaseCounter()
    }
  }

  /// Delete objects with ids from given m ids array. _O(m)_
  ///
  /// - Parameter ids: array of ids.
  public func delete(withIds ids: [Object.ID]) {
    sync {
      ids.forEach { delete(withId: $0) }
    }
  }

  /// Delete all objects in store. _O(1)_
  public func deleteAll() {
    sync {
      store.removePersistentDomain(forName: uniqueIdentifier)
      store.removeSuite(named: uniqueIdentifier)
    }
  }

  /// Count of all objects in store. _O(1)_
  public var objectsCount: Int {
    return store.integer(forKey: counterKey)
  }

  /// Check if store has object with given id. _O(1)_
  ///
  /// - Parameter id: object id to check for.
  /// - Returns: true if the store has an object with the given id.
  public func hasObject(withId id: Object.ID) -> Bool {
    return object(withId: id) != nil
  }

  /// Iterate over all objects in store. _O(n)_
  ///
  /// - Parameter object: iteration block.
  public func forEach(_ object: (Object) -> Void) {
    lock.lock()
    allObjects().forEach { object($0) }
    lock.unlock()
  }
}

// MARK: - Helpers
private extension UserDefaultsStore {
  /// Increase objects count counter.
  func increaseCounter() {
    let currentCount = store.integer(forKey: counterKey)
    store.set(currentCount + 1, forKey: counterKey)
  }

  /// Decrease objects count counter.
  func decreaseCounter() {
    let currentCount = store.integer(forKey: counterKey)
    guard currentCount > 0 else { return }
    guard currentCount - 1 >= 0 else { return }
    store.set(currentCount - 1, forKey: counterKey)
  }
}

// MARK: - Keys
private extension UserDefaultsStore {
  /// counter key.
  var counterKey: String {
    return "\(uniqueIdentifier)-count"
  }

  /// store key for object.
  ///
  /// - Parameter object: object.
  /// - Returns: UserDefaults key for given object.
  func key(for object: Object) -> String {
    return "\(uniqueIdentifier)-\(object.id)"
  }

  /// store key for object by its id.
  ///
  /// - Parameter id: object id.
  /// - Returns: UserDefaults key for given id.
  func key(for id: Object.ID) -> String {
    return "\(uniqueIdentifier)-\(id)"
  }

  /// Check if a UserDefaults key is an object key.
  ///
  /// - Parameter key: UserDefaults key
  /// - Returns: true if the key represents an object key.
  func isObjectKey(_ key: String) -> Bool {
    return key.starts(with: "\(uniqueIdentifier)-")
  }
}
