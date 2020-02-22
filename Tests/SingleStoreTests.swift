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
        let store = createFreshUsersStore()
        XCTAssertNotNil(store)
    }

    func testCreateStoreWithCustomEncoderAndDecoder() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let store = createFreshUsersStore(encoder: encoder, decoder: decoder)
        XCTAssertNotNil(store)
        XCTAssert(store?.encoder === encoder)
        XCTAssert(store?.decoder === decoder)
    }

    func testCreateInvalidStore() {
        let invalidStore = SingleUserDefaultsStore<Bool>(uniqueIdentifier: UserDefaults.globalDomain)
        XCTAssertNil(invalidStore)
    }

    func testSaveObject() {
        let store = createFreshUsersStore()!

        XCTAssertNoThrow(try store.save(TestUser.john))
        XCTAssertNotNil(store.object)
        XCTAssertEqual(store.object!, TestUser.john)
    }

    func testSaveInvalidObject() {
        let store = createFreshUsersStore()!
        XCTAssertThrowsError(try store.save(TestUser.invalid))
    }

    func testObject() {
        let store = createFreshUsersStore()!

        XCTAssertNoThrow(try store.save(TestUser.johnson))
        XCTAssertNotNil(store.object)
    }

}

// MARK: - Helpers
private extension SingleStoreTests {

    func createFreshUsersStore(
        encoder: JSONEncoder = .init(),
        decoder: JSONDecoder = .init()
    ) -> SingleUserDefaultsStore<TestUser>? {
        let store = SingleUserDefaultsStore<TestUser>(
            uniqueIdentifier: "single-user",
            encoder: encoder,
            decoder: decoder
        )
        store?.delete()
        return store
    }

}
