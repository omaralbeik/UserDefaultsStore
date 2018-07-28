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

@testable import UserDefaultsStore

struct TestUser: Codable, Equatable, CustomStringConvertible, Identifiable {
	static let idKey = \TestUser.userId

	var userId: Int
	var firstName: String
	var lastName: String
	var age: Double

	static func == (lhs: TestUser, rhs: TestUser) -> Bool {
		return lhs.userId == rhs.userId
	}

	var description: String {
		return firstName
	}

	static let john = TestUser(userId: 1, firstName: "John", lastName: "Appleseed", age: 21.5)
	static let johnson = TestUser(userId: 2, firstName: "Johnson", lastName: "Smith", age: 26.3)
	static let james = TestUser(userId: 3, firstName: "James", lastName: "Robert", age: 14)

}
