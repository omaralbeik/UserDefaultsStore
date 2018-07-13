//
//  FeedStore.swift
//  HNFeed
//
//  Created by Omar Albeik on 7/12/18.
//  Copyright © 2018 Omar Albeik. All rights reserved.
//

import Foundation
import UserDefaultsStore

class FeedStore {
	private init() {}

	static var ids: [HNItem.ID] {
		get {
			return UserDefaults.standard.value(forKey: "ids") as? [HNItem.ID] ?? []
		}
		set {
			UserDefaults.standard.set(newValue, forKey: "ids")
		}
	}

	static let store = UserDefaultsStore<HNItem>(uniqueIdentifier: "feedStore")!

	static func clear() {
		FeedStore.store.deleteAll()
		FeedStore.ids = []
	}
}
