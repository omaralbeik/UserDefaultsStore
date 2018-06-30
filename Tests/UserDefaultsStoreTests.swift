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

import XCTest
@testable import UserDefaultsStore

private struct User: Codable, Equatable, CustomStringConvertible, Identifiable {
	static let idKey = \User.userId

	var userId: Int
	var firstName: String
	var lastName: String

	static func == (lhs: User, rhs: User) -> Bool {
		return lhs.userId == rhs.userId
	}

	var description: String {
		return firstName
	}

}

final class UserDefaultsStoreTests: XCTestCase {

	fileprivate let john = User(userId: 1, firstName: "John", lastName: "Appleseed")
	fileprivate let johnson = User(userId: 2, firstName: "Johnson", lastName: "Smith")
	fileprivate let james = User(userId: 3, firstName: "James", lastName: "Robert")

	func testCreateStore() {
		let store = createFreshUsersStore()
		XCTAssertNotNil(store)
	}

	func testSetObject() {
		let store = createFreshUsersStore()!
		store.deleteAll()

		try! store.set(john)
		XCTAssertEqual(store.objectsCount, 1)
		XCTAssertEqual(store.getAll(), [john])
	}

	func testGetObject() {
		let store = createFreshUsersStore()!

		try! store.set(johnson)
		XCTAssertNoThrow(try store.get(id: 2))
		let user = try! store.get(id: 2)
		XCTAssertNotNil(user)

		let invalidUser = try! store.get(id: 123)
		XCTAssertNil(invalidUser)
	}

	func testDeleteObject() {
		let store = createFreshUsersStore()!

		try! store.set(james)
		XCTAssertEqual(store.objectsCount, 1)

		store.delete(id: 3)
		XCTAssertEqual(store.objectsCount, 0)
	}

	func testGetAll() {
		let store = createFreshUsersStore()!
		try! store.set(john)
		XCTAssertEqual(store.getAll(), [john])

		try! store.set(johnson)
		XCTAssert(store.getAll().contains(john))
		XCTAssert(store.getAll().contains(johnson))

		try! store.set(james)
		XCTAssert(store.getAll().contains(john))
		XCTAssert(store.getAll().contains(johnson))
		XCTAssert(store.getAll().contains(james))
	}

	func testDeleteAll() {
		let store = createFreshUsersStore()!
		try! store.set(john)
		try! store.set(johnson)
		try! store.set(james)

		store.deleteAll()
		XCTAssert(store.getAll().isEmpty)
	}

	private func createFreshUsersStore() -> UserDefaultsStore<User>? {
		let store = UserDefaultsStore<User>(uniqueIdentifier: "users")
		store?.deleteAll()
		return store
	}

}
