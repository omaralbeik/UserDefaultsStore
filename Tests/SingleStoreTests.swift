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

final class SingleStoreTests: XCTestCase {
  private typealias Snapshot = SingleUserDefaultsStore<TestUser>.Snapshot

  func testCreateStoreWithCustomEncoderAndDecoder() {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    let store = createFreshUserStore(encoder: encoder, decoder: decoder)
    XCTAssertNotNil(store)
    XCTAssert(store.encoder === encoder)
    XCTAssert(store.decoder === decoder)
  }

  func testSaveObject() {
    let store = createFreshUserStore()

    XCTAssertNoThrow(try store.save(TestUser.john))
    XCTAssertNotNil(store.object)
    XCTAssertEqual(store.object!, TestUser.john)
  }

  func testSaveInvalidObject() {
    let store = createFreshUserStore()
    XCTAssertThrowsError(try store.save(TestUser.invalid))
  }

  func testObject() {
    let store = createFreshUserStore()

    XCTAssertNoThrow(try store.save(TestUser.johnson))
    XCTAssertNotNil(store.object)
  }

  func testGenerateSnapshot() {
    let store = createFreshUserStore()

    XCTAssertNoThrow(try store.save(TestUser.john))

    XCTAssertNil(store.lastSnapshotDate)

    let snapshot = store.generateSnapshot()

    XCTAssertEqual(snapshot.object, TestUser.john)
    XCTAssertNotNil(store.lastSnapshotDate)
    XCTAssertEqual(store.lastSnapshotDate, snapshot.dateCreated)
  }

  func testRestoreSnapshot() {
    var store = createFreshUserStore()

    XCTAssertNoThrow(try store.save(TestUser.john))

    let snapshot = store.generateSnapshot()

    store = createFreshUserStore()

    XCTAssertNil(store.lastRestoreDate)
    XCTAssertNoThrow(try store.restoreSnapshot(snapshot))
    XCTAssertNotNil(store.lastRestoreDate)
    XCTAssertEqual(store.object, TestUser.john)
  }

  func testRestoreEmptySnapshot() {
    let store = createFreshUserStore()

    XCTAssertNoThrow(try store.save(TestUser.john))

    let snapshot = SingleUserDefaultsStore<TestUser>.Snapshot(object: nil, dateCreated: Date())

    XCTAssertNoThrow(try store.restoreSnapshot(snapshot))

    XCTAssertNotNil(store.lastRestoreDate)
    XCTAssertNil(store.object)
  }

  func testRestoreSnapshotWithInvalidObjects() {
    let store = createFreshUserStore()

    XCTAssertNoThrow(try store.save(TestUser.john))

    let snapshot = Snapshot(object: TestUser.invalid, dateCreated: Date())

    XCTAssertThrowsError(try store.restoreSnapshot(snapshot))
    XCTAssertNil(store.lastRestoreDate)
    XCTAssertEqual(store.object, TestUser.john)
  }

  func testSnapshotEquality() {
    let now = Date()
    let snapshot1 = Snapshot(object: TestUser.john, dateCreated: now)
    let snapshot2 = Snapshot(object: TestUser.john, dateCreated: now)
    XCTAssertEqual(snapshot1, snapshot2)

    let snapshot3 = Snapshot(object: TestUser.james, dateCreated: Date())
    let snapshot4 = Snapshot(object: TestUser.john, dateCreated: Date())
    XCTAssertNotEqual(snapshot3, snapshot4)
  }
}

// MARK: - Helpers
private extension SingleStoreTests {

  func createFreshUserStore(
    encoder: JSONEncoder = .init(),
    decoder: JSONDecoder = .init()
  ) -> SingleUserDefaultsStore<TestUser> {
    let store = SingleUserDefaultsStore<TestUser>(
      uniqueIdentifier: "single-user",
      encoder: encoder,
      decoder: decoder
    )
    store.delete()
    return store
  }

}
