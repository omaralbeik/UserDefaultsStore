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

/// UserDefaults Store.
open class UserDefaultsStore<T: Codable & Identifiable> {

	/// Store's unique identifier.
	/// **Warning**: Never use the same identifier for two different stores.
	open let uniqueIdentifier: String

	/// JSON encoder _(default is JSONEncoder())_
	open var encoder = JSONEncoder()

	/// JSON decoder _(default is JSONDecoder())_
	open var decoder = JSONDecoder()

	/// UserDefaults store.
	private var store: UserDefaults

	/// Initialize a store with a given identifier.
	///
	/// - Parameter uniqueIdentifier: store's unique identifier.
	required public init(uniqueIdentifier: String) throws {
		guard let store = UserDefaults(suiteName: uniqueIdentifier) else {
			throw UserDefaultsStoreError.unableToCreateStore
		}
		self.uniqueIdentifier = uniqueIdentifier
		self.store = store
	}

	/// Save an object to store. _O(1)_
	///
	/// - Parameter object: object to save.
	/// - Throws: JSON encoding error.
	public func save(_ object: T) throws {
		let data = try encoder.encode(object)
		store.set(data, forKey: key(for: object))
		increaseCounter()
	}

	/// Get an object from store by its id. _O(1)_
	///
	/// - Parameter id: object id.
	/// - Returns: optional object.
	/// - Throws: JSON decoding error.
	public func object(witId id: T.ID) throws -> T {
		guard let data = store.value(forKey: key(for: id)) as? Data else {
			throw UserDefaultsStoreError.objectNotFound
		}
		return try decoder.decode(T.self, from: data)
	}

	/// Delete an object by its id from store. _O(1)_
	///
	/// - Parameter id: object id.
	public func delete(witId id: T.ID) {
		guard let object = try? object(witId: id) else { return }
		store.removeObject(forKey: key(for: object))
		decreaseCounter()
	}

	/// Get all objects from store. _O(n)_
	///
	/// - Returns: array of all objects in store.
	public func allObjects() -> [T] {
		guard objectsCount > 0 else { return [] }

		var objects: [T] = []
		for key in store.dictionaryRepresentation().keys {
			guard isObjectKey(key) else { continue }
			guard let data = store.data(forKey: key) else { continue }
			guard let object = try? decoder.decode(T.self, from: data) else { continue }
			objects.append(object)
		}
		return objects
	}

	/// Delete all objects in store. _O(1)_
	public func deleteAll() {
		store.removePersistentDomain(forName: uniqueIdentifier)
	}

	/// Count of all objects in store. _O(1)_
	public var objectsCount: Int {
		return store.integer(forKey: counterKey)
	}

}

// MARK: - Helpers
private extension UserDefaultsStore {

	/// Increase objects count counter.
	func increaseCounter() {
		let int = store.integer(forKey: counterKey)
		store.set(int + 1, forKey: counterKey)
	}

	/// Decrease objects count counter.
	func decreaseCounter() {
		let int = store.integer(forKey: counterKey)
		guard int > 0 else { return }
		store.set(int - 1, forKey: counterKey)
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
	func key(for object: T) -> String {
		return "\(uniqueIdentifier)-\(object[keyPath: T.idKey].hashValue)"
	}

	/// store key for object by its id.
	///
	/// - Parameter id: object id.
	/// - Returns: UserDefaults key for given id.
	func key(for id: T.ID) -> String {
		return "\(uniqueIdentifier)-\(id.hashValue)"
	}

	/// Check if a UserDefaults key is an object key.
	///
	/// - Parameter key: UserDefaults key
	/// - Returns: true if the key represents an object key.
	func isObjectKey(_ key: String) -> Bool {
		return key.starts(with: "\(uniqueIdentifier)-")
	}

}
