//
//  UIViewController+Extensions.swift
//  HNFeed
//
//  Created by Omar Albeik on 7/13/18.
//  Copyright © 2018 Omar Albeik. All rights reserved.
//

import UIKit

extension UIViewController {

	func showAlert(message: String) {
		let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK", style: .default)
		alertController.addAction(okAction)

		present(alertController, animated: true)
	}

}
