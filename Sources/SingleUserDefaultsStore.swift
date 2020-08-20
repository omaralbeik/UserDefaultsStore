//
//  SingleUserDefaultsStore
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

/// `SingleUserDefaultsStore` offers a convenient way to store a single `Codable` object in `UserDefaults`.
open class SingleUserDefaultsStore<Object: Codable> {
    /// Used to backup and restore content to store.
    public struct Snapshot: Codable {
        /// Object.
        public let object: Object?

        /// Date when the snapshot was created.
        public let dateCreated: Date

        /// Create a new `Snapshot`.
        /// - Parameters:
        ///   - object: Object to include in the snapshot.
        ///   - dateCreated: Date when the snapshot was created.
        public init(object: Object?, dateCreated: Date) {
            self.object = object
            self.dateCreated = dateCreated
        }
    }

    /// Store's unique identifier.
    ///
    /// **Warning**: Never use the same identifier for two -or more- different stores.
    public let uniqueIdentifier: String

    /// JSON encoder to be used for encoding object to be stored.
    open var encoder: JSONEncoder

    /// JSON decoder to be used to decode the stored object.
    open var decoder: JSONDecoder

    /// UserDefaults store.
    private let store: UserDefaults

    /// Initialize store with given identifier. _O(1)_
    ///
    /// **Warning**: Never use the same identifier for two -or more- different stores.
    ///
    /// - Parameter uniqueIdentifier: store's unique identifier.
    /// - Parameter encoder: JSON encoder to be used for encoding object to be stored. _default is `JSONEncoder()`_
    /// - Parameter decoder: JSON decoder to be used to decode the stored object. _default is `JSONDecoder()`_
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
        let data = try encoder.encode(generateDict(for: object))
        store.set(data, forKey: key)
    }

    /// Get object from store. _O(1)_
    public var object: Object? {
        guard let data = store.data(forKey: key) else { return nil }
        guard let dict = try? decoder.decode([String: Object].self, from: data) else { return nil }
        return extractObject(from: dict)
    }

    /// Delete object from store. _O(1)_
    public func delete() {
        store.removePersistentDomain(forName: uniqueIdentifier)
        store.removeSuite(named: uniqueIdentifier)
    }

    /// Generate a snapshot that can be saved and restored later. _O(1)_
    /// - Returns: `Snapshot` object representing current contents of the store.
    public func generateSnapshot() -> Snapshot {
        let now = Date()
        store.setValue(now, forKey: lastSnapshotDateKey)
        return Snapshot(object: object, dateCreated: now)
    }

    /// Restore a pre-generated `Snapshot`. _O(1)_
    /// - Parameter snapshot: `Snapshot` to restore.
    /// - Throws: JSON encoding/decoding error.
    public func restoreSnapshot(_ snapshot: Snapshot) throws {
        let now = Date()
        guard let object = snapshot.object else {
            delete()
            store.setValue(now, forKey: lastRestoreDateKey)
            return
        }

        let current = self.object
        delete()
        do {
            try save(object)
            store.setValue(now, forKey: lastRestoreDateKey)
        } catch {
            if let current = current {
                try save(current)
            }
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

extension SingleUserDefaultsStore.Snapshot: Equatable where Object: Equatable {
    /// Returns a Boolean value indicating whether two snapshots are equal.
    ///
    /// - Parameters:
    ///   - lhs: A `Snapshot` object to compare.
    ///   - rhs: Another `Snapshot` object to compare.
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.object == rhs.object && lhs.dateCreated == rhs.dateCreated
    }
}

// MARK: - Helpers
private extension SingleUserDefaultsStore {
    /// Enclose the object in a dictionary to enable single object storing.
    ///
    /// - Parameter object: object.
    /// - Returns: dictionary enclosing object.
    func generateDict(for object: Object) -> [String: Object] {
        return ["object": object]
    }

    /// Extract object from dictionary.
    ///
    /// - Parameter dict: dictionary.
    /// - Returns: object.
    func extractObject(from dict: [String: Object]) -> Object? {
        return dict["object"]
    }

    /// Store key for object.
    var key: String {
        return "\(uniqueIdentifier)-single-object"
    }

    /// last snapshot date key.
    var lastSnapshotDateKey: String {
        return "\(uniqueIdentifier)-single-object-last-snapshot-date"
    }

    /// last restore date key.
    var lastRestoreDateKey: String {
        return "\(uniqueIdentifier)-single-object-last-restore-date"
    }
}
