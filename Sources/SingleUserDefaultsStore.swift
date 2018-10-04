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
open class SingleUserDefaultsStore<T: Codable> {

	/// Store's unique identifier.
	///
	/// **Warning**: Never use the same identifier for two -or more- different stores.
	public let uniqueIdentifier: String

	/// JSON encoder. _default is `JSONEncoder()`_
	open var encoder = JSONEncoder()

	/// JSON decoder. _default is `JSONDecoder()`_
	open var decoder = JSONDecoder()

	/// UserDefaults store.
	private var store: UserDefaults

	/// Initialize store with given identifier.
	///
	/// **Warning**: Never use the same identifier for two -or more- different stores.
	///
	/// - Parameter uniqueIdentifier: store's unique identifier.
	required public init?(uniqueIdentifier: String) {
		guard let store = UserDefaults(suiteName: uniqueIdentifier) else { return nil }
		self.uniqueIdentifier = uniqueIdentifier
		self.store = store
	}

	/// Save object to store. _O(1)_
	///
	/// - Parameter object: object to save.
	/// - Throws: JSON encoding error.
	public func save(_ object: T) throws {
		let data = try encoder.encode(generateDict(for: object))
		store.set(data, forKey: key)
	}

	/// Get object from store. _O(1)_
	public var object: T? {
		guard let data = store.data(forKey: key) else { return nil }
		guard let dict = try? decoder.decode([String: T].self, from: data) else { return nil }
		return extractObject(from: dict)
	}

	/// Delete object from store. _O(1)_
	public func delete() {
		store.set(nil, forKey: key)
		store.removeSuite(named: uniqueIdentifier)
	}

}

// MARK: - Helpers
private extension SingleUserDefaultsStore {

	/// Enclose the object in a dictionary to enable single object storing.
	///
	/// - Parameter object: object.
	/// - Returns: dictionary enclosing object.
	func generateDict(for object: T) -> [String: T] {
		return ["object": object]
	}

	/// Extract object from dictionary.
	///
	/// - Parameter dict: dictionary.
	/// - Returns: object.
	func extractObject(from dict: [String: T]) -> T? {
		return dict["object"]
	}

	/// Store key for object.
	var key: String {
		return "\(uniqueIdentifier)-single-object"
	}

}
