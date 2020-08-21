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
open class UserDefaultsStore<Object: Codable & Identifiable> {
    /// Used to backup and restore content to store.
    public struct Snapshot: Codable {
        /// Array of objects.
        public let objects: [Object]

        /// Date when the snapshot was created.
        public let dateCreated: Date

        /// Create a new `Snapshot`.
        /// - Parameters:
        ///   - object: Array of objects to include in the snapshot.
        ///   - dateCreated: Date when the snapshot was created.
        public init(objects: [Object], dateCreated: Date) {
            self.objects = objects
            self.dateCreated = dateCreated
        }
    }

    /// Store's unique identifier.
    ///
    /// **Warning**: Never use the same identifier for two -or more- different stores.
    public let uniqueIdentifier: String

    /// JSON encoder to be used for encoding objects to be stored.
    open var encoder: JSONEncoder

    /// JSON decoder to be used to decode stored objects.
    open var decoder: JSONDecoder

    /// UserDefaults store.
    private let store: UserDefaults

    /// Initialize store with given identifier. _O(1)_
    ///
    /// **Warning**: Never use the same identifier for two -or more- different stores.
    ///
    /// - Parameter uniqueIdentifier: store's unique identifier.
    /// - Parameter encoder: JSON encoder to be used for encoding objects to be stored. _default is `JSONEncoder()`_
    /// - Parameter decoder: JSON decoder to be used to decode stored objects. _default is `JSONDecoder()`_
    required public init(
        uniqueIdentifier: String,
        encoder: JSONEncoder = .init(),
        decoder: JSONDecoder = .init()
    ) {
        guard let store = UserDefaults(suiteName: uniqueIdentifier) else {
            fatalError("Can not create a store with identifier: '\(uniqueIdentifier)'.")
        }
        self.uniqueIdentifier = uniqueIdentifier
        self.encoder = encoder
        self.decoder = decoder
        self.store = store
    }

    /// Save object to store. _O(1)_
    ///
    /// - Parameter object: object to save.
    /// - Throws: JSON encoding error.
    public func save(_ object: Object) throws {
        let data = try encoder.encode(object)
        store.set(data, forKey: key(for: object))
        increaseCounter()
    }

    /// Save optional object (if not nil) to store. _O(1)_
    ///
    /// - Parameter optionalObject: optional object to save.
    /// - Throws: JSON encoding error.
    public func save(_ optionalObject: Object?) throws {
        guard let object = optionalObject else { return }
        try save(object)
    }

    /// Save array of m objects to store. _O(m)_
    ///
    /// - Parameter objects: object to save.
    /// - Throws: JSON encoding error.
    public func save(_ objects: [Object]) throws {
        let pairs = try objects.map({ (key: key(for: $0), data: try encoder.encode($0)) })
        pairs.forEach { pair in
            store.set(pair.data, forKey: pair.key)
            increaseCounter()
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
        guard hasObject(withId: id) else { return }
        store.removeObject(forKey: key(for: id))
        decreaseCounter()
    }

    /// Delete objects with ids from given m ids array. _O(m)_
    ///
    /// - Parameter ids: array of ids.
    public func delete(withIds ids: [Object.ID]) {
        ids.forEach { delete(withId: $0) }
    }

    /// Delete all objects in store. _O(1)_
    public func deleteAll() {
        store.removePersistentDomain(forName: uniqueIdentifier)
        store.removeSuite(named: uniqueIdentifier)
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
        allObjects().forEach { object($0) }
    }

    /// Generate a snapshot that can be saved and restored later. _O(n)_
    /// - Returns: `Snapshot` object representing current contents of the store.
    public func generateSnapshot() -> Snapshot {
        let now = Date()
        store.setValue(now, forKey: lastSnapshotDateKey)
        return Snapshot(objects: allObjects(), dateCreated: now)
    }

    /// Restore a pre-generated `Snapshot`. _O(n)_
    /// - Parameter snapshot: `Snapshot` to restore.
    /// - Throws: JSON encoding/decoding error.
    public func restoreSnapshot(_ snapshot: Snapshot) throws {
        let now = Date()
        guard !snapshot.objects.isEmpty else {
            deleteAll()
            store.setValue(now, forKey: lastRestoreDateKey)
            return
        }

        let current = allObjects()
        deleteAll()
        do {
            try save(snapshot.objects)
            store.setValue(now, forKey: lastRestoreDateKey)
        } catch {
            try save(current)
            throw error
        }
    }

    /// Date when the last `Snapshot` was generated.
    public var lastSnapshotDate: Date? {
        return store.value(forKey: lastSnapshotDateKey) as? Date
    }

    /// Date when the last `Snapshot` was successfully restored.
    public var lastRestoreDate: Date? {
        return store.value(forKey: lastRestoreDateKey) as? Date
    }
}

extension UserDefaultsStore.Snapshot: Equatable where Object: Equatable {
    /// Returns a Boolean value indicating whether two snapshots are equal.
    ///
    /// - Parameters:
    ///   - lhs: A `Snapshot` object to compare.
    ///   - rhs: Another `Snapshot` object to compare.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.objects == rhs.objects && lhs.dateCreated == rhs.dateCreated
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

    /// last snapshot date key.
    var lastSnapshotDateKey: String {
        return "\(uniqueIdentifier)-last-snapshot-date"
    }

    /// last restore date key.
    var lastRestoreDateKey: String {
        return "\(uniqueIdentifier)-last-restore-date"
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
