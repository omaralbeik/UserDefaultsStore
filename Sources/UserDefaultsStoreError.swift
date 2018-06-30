//
//  UserDefaultsStoreError.swift
//  UserDefaultsStore
//
//  Created by Omar Albeik on 6/30/18.
//  Copyright © 2018 Omar Albeik. All rights reserved.
//

import Foundation

/// UserDefaultsStore Error.
///
/// - unableToCreateStore: Unable to create a store.
/// - objectNotFound: Object not found in store.
public enum UserDefaultsStoreError: LocalizedError {
	case unableToCreateStore
	case objectNotFound
}
