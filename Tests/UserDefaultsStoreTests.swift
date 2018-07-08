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
	var age: Double

	static func == (lhs: User, rhs: User) -> Bool {
		return lhs.userId == rhs.userId
	}

	var description: String {
		return firstName
	}

}

final class UserDefaultsStoreTests: XCTestCase {

	fileprivate let john = User(userId: 1, firstName: "John", lastName: "Appleseed", age: 21.5)
	fileprivate let johnson = User(userId: 2, firstName: "Johnson", lastName: "Smith", age: 26.3)
	fileprivate let james = User(userId: 3, firstName: "James", lastName: "Robert", age: 14)

	func testCreateStore() {
		let store = createFreshUsersStore()
		XCTAssertNotNil(store)
	}

	func testSaveObject() {
		let store = createFreshUsersStore()!

		XCTAssertNoThrow(try store.save(john))
		XCTAssertEqual(store.objectsCount, 1)
		XCTAssertEqual(store.allObjects(), [john])
	}

	func testSaveOptional() {
		let store = createFreshUsersStore()!

		XCTAssertNoThrow(try store.save(nil))
		XCTAssertEqual(store.objectsCount, 0)

		XCTAssertNoThrow(try store.save(john))
		XCTAssertEqual(store.objectsCount, 1)
		XCTAssertEqual(store.allObjects(), [john])
	}

	func testSaveInvalidObject() {
		let store = createFreshUsersStore()!

		let user = User(userId: 5, firstName: "firstName", lastName: "lastName", age: .nan)

		let optionalUser: User? = user

		XCTAssertThrowsError(try store.save(user))
		XCTAssertThrowsError(try store.save(optionalUser))
	}

	func testSaveObjects() {
		let store = createFreshUsersStore()!

		XCTAssertNoThrow(try store.save([john, johnson, james]))
		XCTAssertEqual(store.objectsCount, 3)
		XCTAssert(store.allObjects().contains(john))
		XCTAssert(store.allObjects().contains(johnson))
		XCTAssert(store.allObjects().contains(james))
	}

	func testObject() {
		let store = createFreshUsersStore()!

		XCTAssertNoThrow(try store.save(johnson))
		let user = store.object(withId: 2)
		XCTAssertNotNil(user)

		let invalidUser = store.object(withId: 123)
		XCTAssertNil(invalidUser)
	}

	func testObjects() {
		let store = createFreshUsersStore()!

		XCTAssertNoThrow(try store.save(james))
		XCTAssertNoThrow(try store.save(johnson))

		let users = store.objects(withIds: [james.userId, johnson.userId, 5])
		XCTAssertEqual(users.count, 2)
		XCTAssert(users.contains(james))
		XCTAssert(users.contains(johnson))
	}

	func testDeleteObject() {
		let store = createFreshUsersStore()!

		XCTAssertNoThrow(try store.save(james))

		XCTAssertEqual(store.objectsCount, 1)

		store.delete(withId: 3)
		XCTAssertEqual(store.objectsCount, 0)
	}

	func testDeleteObjects() {
		let store = createFreshUsersStore()!

		XCTAssertNoThrow(try store.save(james))
		XCTAssertNoThrow(try store.save(johnson))

		XCTAssertEqual(store.objectsCount, 2)

		store.delete(withIds: [james.userId, 5, 6, 8])
		XCTAssertEqual(store.objectsCount, 1)
	}

	func testGetAll() {
		let store = createFreshUsersStore()!

		XCTAssertNoThrow(try store.save(john))
		XCTAssertEqual(store.allObjects(), [john])

		XCTAssertNoThrow(try store.save(johnson))
		XCTAssert(store.allObjects().contains(john))
		XCTAssert(store.allObjects().contains(johnson))

		XCTAssertNoThrow(try store.save(james))
		XCTAssert(store.allObjects().contains(john))
		XCTAssert(store.allObjects().contains(johnson))
		XCTAssert(store.allObjects().contains(james))
	}

	func testDeleteAll() {
		let store = createFreshUsersStore()!

		XCTAssertNoThrow(try store.save(john))
		XCTAssertNoThrow(try store.save(johnson))
		XCTAssertNoThrow(try store.save(james))

		store.deleteAll()
		XCTAssert(store.allObjects().isEmpty)
	}

	private func createFreshUsersStore() -> UserDefaultsStore<User>? {
		let store = UserDefaultsStore<User>(uniqueIdentifier: "users")
		store?.deleteAll()
		return store
	}

}
