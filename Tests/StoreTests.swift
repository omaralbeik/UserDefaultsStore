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
  private typealias Snapshot = UserDefaultsStore<TestUser>.Snapshot

  func testCreateStoreWithCustomEncoderAndDecoder() {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    let store = createFreshUsersStore(encoder: encoder, decoder: decoder)
    XCTAssertNotNil(store)
    XCTAssert(store.encoder === encoder)
    XCTAssert(store.decoder === decoder)
  }

  func testCreateStoreWithCustomDecoder() {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .useDefaultKeys

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    let store = createFreshUsersStore(encoder: encoder, decoder: decoder)
    XCTAssertNotNil(store)

    XCTAssertNoThrow(try store.save(TestUser.john))
    XCTAssertEqual(store.object(withId: TestUser.john.id), TestUser.john)
  }

  func testSaveObject() {
    let store = createFreshUsersStore()

    XCTAssertNoThrow(try store.save(TestUser.john))
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [TestUser.john])
  }

  func testSaveOptional() {
    let store = createFreshUsersStore()

    XCTAssertNoThrow(try store.save(nil))
    XCTAssertEqual(store.objectsCount, 0)

    XCTAssertNoThrow(try store.save(TestUser.john))
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [TestUser.john])
  }

  func testSaveInvalidObject() {
    let store = createFreshUsersStore()

    let optionalUser: TestUser? = TestUser.invalid
    XCTAssertThrowsError(try store.save(TestUser.invalid))
    XCTAssertThrowsError(try store.save(optionalUser))
  }

  func testSaveObjects() {
    let store = createFreshUsersStore()

    XCTAssertNoThrow(try store.save([TestUser.john, TestUser.johnson, TestUser.james]))
    XCTAssertEqual(store.objectsCount, 3)
    XCTAssert(store.allObjects().contains(TestUser.john))
    XCTAssert(store.allObjects().contains(TestUser.johnson))
    XCTAssert(store.allObjects().contains(TestUser.james))
  }

  func testSaveInvalidObjects() {
    let store = createFreshUsersStore()

    XCTAssertThrowsError(try store.save([TestUser.james, TestUser.john, TestUser.invalid]))
    XCTAssertEqual(store.objectsCount, 0)
    XCTAssertEqual(store.allObjects(), [])
  }

  func testObject() {
    let store = createFreshUsersStore()

    XCTAssertNoThrow(try store.save(TestUser.johnson))
    let user = store.object(withId: 2)
    XCTAssertNotNil(user)

    let invalidUser = store.object(withId: 123)
    XCTAssertNil(invalidUser)
  }

  func testObjects() {
    let store = createFreshUsersStore()

    XCTAssertNoThrow(try store.save(TestUser.james))
    XCTAssertNoThrow(try store.save(TestUser.johnson))

    let users = store.objects(withIds: [TestUser.james.id, TestUser.johnson.id, 5])
    XCTAssertEqual(users.count, 2)
    XCTAssert(users.contains(TestUser.james))
    XCTAssert(users.contains(TestUser.johnson))
  }

  func testDeleteObject() {
    let store = createFreshUsersStore()

    XCTAssertNoThrow(try store.save(TestUser.james))

    XCTAssertEqual(store.objectsCount, 1)

    store.delete(withId: 3)
    XCTAssertEqual(store.objectsCount, 0)
  }

  func testDeleteObjects() {
    let store = createFreshUsersStore()

    XCTAssertNoThrow(try store.save(TestUser.james))
    XCTAssertNoThrow(try store.save(TestUser.johnson))

    XCTAssertEqual(store.objectsCount, 2)

    store.delete(withIds: [TestUser.james.id, 5, 6, 8])
    XCTAssertEqual(store.objectsCount, 1)
  }

  func testGetAll() {
    let store = createFreshUsersStore()

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
    let store = createFreshUsersStore()

    XCTAssertNoThrow(try store.save(TestUser.john))
    XCTAssertNoThrow(try store.save(TestUser.johnson))
    XCTAssertNoThrow(try store.save(TestUser.james))

    store.deleteAll()
    XCTAssert(store.allObjects().isEmpty)
  }

  func testHasObject() {
    let store = createFreshUsersStore()
    XCTAssertFalse(store.hasObject(withId: 10))

    XCTAssertNoThrow(try store.save(TestUser.john))
    XCTAssert(store.hasObject(withId: TestUser.john.id))
  }

  func testForEach() {
    let store = createFreshUsersStore()

    let users = [TestUser.john, TestUser.johnson, TestUser.james]
    XCTAssertNoThrow(try store.save(users))

    var counter = 0
    store.forEach { user in
      XCTAssert(users.contains(user))
      counter += 1
    }
    XCTAssertEqual(counter, 3)
  }

  func testGenerateSnapshot() {
    let store = createFreshUsersStore()

    let users = [TestUser.john, TestUser.johnson].sorted()
    XCTAssertNoThrow(try store.save(users))

    XCTAssertNil(store.lastSnapshotDate)

    let snapshot = store.generateSnapshot()

    XCTAssertEqual(snapshot.objects.sorted(), users)
    XCTAssertNotNil(store.lastSnapshotDate)
    XCTAssertEqual(store.lastSnapshotDate, snapshot.dateCreated)
  }

  func testRestoreSnapshot() {
    var store = createFreshUsersStore()

    let users = [TestUser.john, TestUser.johnson].sorted()
    XCTAssertNoThrow(try store.save(users))

    let snapshot = store.generateSnapshot()

    store = createFreshUsersStore()

    XCTAssertNil(store.lastRestoreDate)
    XCTAssertNoThrow(try store.restoreSnapshot(snapshot))
    XCTAssertNotNil(store.lastRestoreDate)
    XCTAssertEqual(store.allObjects().sorted(), users)
  }

  func testRestoreEmptySnapshot() {
    let store = createFreshUsersStore()

    let users = [TestUser.john, TestUser.johnson]
    XCTAssertNoThrow(try store.save(users))

    let snapshot = Snapshot(objects: [], dateCreated: Date())

    XCTAssertNoThrow(try store.restoreSnapshot(snapshot))

    XCTAssertNotNil(store.lastRestoreDate)
    XCTAssertEqual(store.objectsCount, 0)
  }

  func testRestoreSnapshotWithInvalidObjects() {
    let store = createFreshUsersStore()

    let users = [TestUser.john, TestUser.johnson]
    XCTAssertNoThrow(try store.save(users))

    let snapshot = Snapshot(objects: [TestUser.invalid], dateCreated: Date())

    XCTAssertThrowsError(try store.restoreSnapshot(snapshot))
    XCTAssertNil(store.lastRestoreDate)
    XCTAssertEqual(store.objectsCount, users.count)
    XCTAssert(store.hasObject(withId: TestUser.john.id))
    XCTAssert(store.hasObject(withId: TestUser.johnson.id))
  }

  func testSnapshotEquality() {
    let now = Date()
    let snapshot1 = Snapshot(objects: [TestUser.john], dateCreated: now)
    let snapshot2 = Snapshot(objects: [TestUser.john], dateCreated: now)
    XCTAssertEqual(snapshot1, snapshot2)

    let snapshot3 = Snapshot(objects: [TestUser.john], dateCreated: Date())
    let snapshot4 = Snapshot(objects: [TestUser.john], dateCreated: Date().addingTimeInterval(1))
    XCTAssertNotEqual(snapshot3, snapshot4)
  }
}

// MARK: - Helpers
private extension StoreTests {
  func createFreshUsersStore(
    encoder: JSONEncoder = .init(),
    decoder: JSONDecoder = .init()
  ) -> UserDefaultsStore<TestUser> {
    let store = UserDefaultsStore<TestUser>(
      uniqueIdentifier: "users",
      encoder: encoder,
      decoder: decoder
    )
    store.deleteAll()
    return store
  }
}
