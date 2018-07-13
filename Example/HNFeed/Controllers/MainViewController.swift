//
//  MainViewController.swift
//  HNFeed
//
//  Created by Omar Albeik on 7/13/18.
//  Copyright © 2018 Omar Albeik. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

	@IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

	var isShowingCachedFeed = false

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		guard segue.identifier == "toFeedSegue" else { return }
		guard let navController = segue.destination as? UINavigationController else { return }
		guard let feedController = navController.viewControllers.first as? FeedTableViewController else { return }
		feedController.shouldShowFetchNextFooter = !isShowingCachedFeed
	}

}

// MARK: - Actions
private extension MainViewController {

	@IBAction func didTapFetchButton(_ sender: UIButton) {
		isShowingCachedFeed = false

		loadingIndicator.startAnimating()

		API.feedProvider.request(.list) { result in
			self.loadingIndicator.stopAnimating()

			switch result {
			case .failure(let error):
				self.showAlert(message: error.localizedDescription)

			case .success(let response):
				FeedStore.clear()
				FeedStore.ids = response.items ?? []
				self.showFeedController()
			}
		}
	}

	@IBAction func didTapLoadCachedButton(_ sender: UIButton) {
		isShowingCachedFeed = true
		showFeedController()
	}

}

// MARK: - Helpers
private extension MainViewController {

	func showFeedController() {
		performSegue(withIdentifier: "toFeedSegue", sender: self)
	}

}
