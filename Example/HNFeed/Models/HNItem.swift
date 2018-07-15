//
//  HNItem.swift
//  HNFeed
//
//  Created by Omar Albeik on 7/12/18.
//  Copyright © 2018 Omar Albeik. All rights reserved.
//

import Foundation
import UserDefaultsStore

struct HNItem: Codable, Identifiable {
	static var idKey = \HNItem.id

	var id: Int
	var title: String?
	var url: URL?

}
