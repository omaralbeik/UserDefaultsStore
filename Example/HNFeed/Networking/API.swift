//
//  API.swift
//  HNFeed
//
//  Created by Omar Albeik on 7/13/18.
//  Copyright © 2018 Omar Albeik. All rights reserved.
//

import Foundation
import Moya

class API {
	private init() {}

	static let feedProvider = MoyaProvider<FeedService>()

}
