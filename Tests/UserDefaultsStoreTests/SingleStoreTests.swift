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
  func testCreateStore() {
    let uniqueIdentifier = UUID().uuidString
    let store = createFreshUserStore(uniqueIdentifier: uniqueIdentifier)
    XCTAssertEqual(store.uniqueIdentifier, uniqueIdentifier)
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
}

// MARK: - Helpers
private extension SingleStoreTests {
  func createFreshUserStore(uniqueIdentifier: String = "single-user") -> SingleUserDefaultsStore<TestUser> {
    let store = SingleUserDefaultsStore<TestUser>(uniqueIdentifier: uniqueIdentifier)
    store.delete()
    return store
  }

}
