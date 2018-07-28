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

final class StoreTests: XCTestCase {

	func testCreateStore() {
		let store = createFreshUsersStore()
		XCTAssertNotNil(store)
	}

	func testSaveObject() {
		let store = createFreshUsersStore()!

		XCTAssertNoThrow(try store.save(TestUser.john))
		XCTAssertEqual(store.objectsCount, 1)
		XCTAssertEqual(store.allObjects(), [TestUser.john])
	}

	func testSaveOptional() {
		let store = createFreshUsersStore()!

		XCTAssertNoThrow(try store.save(nil))
		XCTAssertEqual(store.objectsCount, 0)

		XCTAssertNoThrow(try store.save(TestUser.john))
		XCTAssertEqual(store.objectsCount, 1)
		XCTAssertEqual(store.allObjects(), [TestUser.john])
	}

	func testSaveInvalidObject() {
		let store = createFreshUsersStore()!

		let user = TestUser(userId: 5, firstName: "firstName", lastName: "lastName", age: .nan)

		let optionalUser: TestUser? = user

		XCTAssertThrowsError(try store.save(user))
		XCTAssertThrowsError(try store.save(optionalUser))
	}

	func testSaveObjects() {
		let store = createFreshUsersStore()!

		XCTAssertNoThrow(try store.save([TestUser.john, TestUser.johnson, TestUser.james]))
		XCTAssertEqual(store.objectsCount, 3)
		XCTAssert(store.allObjects().contains(TestUser.john))
		XCTAssert(store.allObjects().contains(TestUser.johnson))
		XCTAssert(store.allObjects().contains(TestUser.james))
	}

	func testObject() {
		let store = createFreshUsersStore()!

		XCTAssertNoThrow(try store.save(TestUser.johnson))
		let user = store.object(withId: 2)
		XCTAssertNotNil(user)

		let invalidUser = store.object(withId: 123)
		XCTAssertNil(invalidUser)
	}

	func testObjects() {
		let store = createFreshUsersStore()!

		XCTAssertNoThrow(try store.save(TestUser.james))
		XCTAssertNoThrow(try store.save(TestUser.johnson))

		let users = store.objects(withIds: [TestUser.james.userId, TestUser.johnson.userId, 5])
		XCTAssertEqual(users.count, 2)
		XCTAssert(users.contains(TestUser.james))
		XCTAssert(users.contains(TestUser.johnson))
	}

	func testDeleteObject() {
		let store = createFreshUsersStore()!

		XCTAssertNoThrow(try store.save(TestUser.james))

		XCTAssertEqual(store.objectsCount, 1)

		store.delete(withId: 3)
		XCTAssertEqual(store.objectsCount, 0)
	}

	func testDeleteObjects() {
		let store = createFreshUsersStore()!

		XCTAssertNoThrow(try store.save(TestUser.james))
		XCTAssertNoThrow(try store.save(TestUser.johnson))

		XCTAssertEqual(store.objectsCount, 2)

		store.delete(withIds: [TestUser.james.userId, 5, 6, 8])
		XCTAssertEqual(store.objectsCount, 1)
	}

	func testGetAll() {
		let store = createFreshUsersStore()!

		XCTAssertNoThrow(try store.save(TestUser.john))
		XCTAssertEqual(store.allObjects(), [TestUser.john])

		XCTAssertNoThrow(try store.save(TestUser.johnson))
		XCTAssert(store.allObjects().contains(TestUser.john))
		XCTAssert(store.allObjects().contains(TestUser.johnson))

		XCTAssertNoThrow(try store.save(TestUser.james))
		XCTAssert(store.allObjects().contains(TestUser.john))
		XCTAssert(store.allObjects().contains(TestUser.johnson))
		XCTAssert(store.allObjects().contains(TestUser.james))
	}

	func testDeleteAll() {
		let store = createFreshUsersStore()!

		XCTAssertNoThrow(try store.save(TestUser.john))
		XCTAssertNoThrow(try store.save(TestUser.johnson))
		XCTAssertNoThrow(try store.save(TestUser.james))

		store.deleteAll()
		XCTAssert(store.allObjects().isEmpty)
	}

	func testHasObject() {
		let store = createFreshUsersStore()!
		XCTAssertFalse(store.hasObject(withId: 10))

		XCTAssertNoThrow(try store.save(TestUser.john))
		XCTAssert(store.hasObject(withId: TestUser.john.userId))
	}

	func testForEach() {
		let store = createFreshUsersStore()!

		let users = [TestUser.john, TestUser.johnson, TestUser.james]
		XCTAssertNoThrow(try store.save(users))

		var counter = 0
		store.forEach { user in
			XCTAssert(users.contains(user))
			counter += 1
		}
		XCTAssertEqual(counter, 3)
	}

}

// MARK: - Helpers
private extension StoreTests {

	func createFreshUsersStore() -> UserDefaultsStore<TestUser>? {
		let store = UserDefaultsStore<TestUser>(uniqueIdentifier: "users")
		store?.deleteAll()
		return store
	}

}
