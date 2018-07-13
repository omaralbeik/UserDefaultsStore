//
//  FeedService.swift
//  HNFeed
//
//  Created by Omar Albeik on 7/13/18.
//  Copyright © 2018 Omar Albeik. All rights reserved.
//

import Foundation
import Moya

enum FeedService {
	case list
	case item(id: HNItem.ID)
}

extension FeedService: TargetType {

	var baseURL: URL {
		return URL(string: "https://hacker-news.firebaseio.com/v0")!
	}

	var path: String {
		switch self {
		case .list:
			return "topstories.json"
		case .item(let id):
			return "item/\(id).json"
		}
	}

	var method: Moya.Method {
		switch self {
		case .list,
			 .item:
			return .get
		}
	}

	var task: Task {
		switch self {
		case .list,
			 .item:
			return .requestPlain
		}
	}

	var headers: [String: String]? {
		switch self {
		case .list,
			 .item:
			return nil
		}
	}

	var sampleData: Data {
		return "".data(using: .utf8)!
	}

}

extension Response {

	var items: [HNItem.ID]? {
		return try? map([HNItem.ID].self)
	}

	var item: HNItem? {
		return try? map(HNItem.self)
	}

}
