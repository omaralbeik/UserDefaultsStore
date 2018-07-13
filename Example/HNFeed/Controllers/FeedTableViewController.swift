//
//  FeedTableViewController.swift
//  HNFeed
//
//  Created by Omar Albeik on 7/12/18.
//  Copyright © 2018 Omar Albeik. All rights reserved.
//

import UIKit

class FeedTableViewController: UITableViewController {

	var ids: [HNItem.ID] = FeedStore.ids
	var items = FeedStore.store.allObjects()

	var shouldShowFetchNextFooter = true {
		didSet {
			if !shouldShowFetchNextFooter {
				tableView.tableFooterView = nil
			}
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

		FeedStore.clear()
		tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		return configureCell(cell, forItem: items[indexPath.row])
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let url = items[indexPath.row].url {
			UIApplication.shared.open(url, options: [:])
		}
	}

}

// MARK: - Actions
private extension FeedTableViewController {

	@IBAction func didTapCancelBarButtonItem(_ sender: UIBarButtonItem) {
		dismiss(animated: true, completion: nil)
	}

	@IBAction func didTapFetchButton(_ sender: UIButton) {
		let number = min(ids.count, 50)

		sender.isEnabled = number > 0

		let nextIds = ids.prefix(number)
		ids.removeFirst(number)

		for id in nextIds {
			fetchItem(id: id)
		}
	}

}

// MARK: - Helpers
private extension FeedTableViewController {

	func fetchItem(id: HNItem.ID) {
		API.feedProvider.request(.item(id: id)) { result in
			switch result {
			case .failure(let error):
				debugPrint(error.localizedDescription)
			case .success(let response):
				guard let item = response.item else { return }
				try? FeedStore.store.save(item)
				self.items.append(item)
				let row = self.tableView.numberOfRows(inSection: 0)
				self.tableView.insertRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
			}
		}
	}

	func configureCell(_ cell: UITableViewCell, forItem item: HNItem) -> UITableViewCell {
		cell.textLabel?.numberOfLines = 0
		cell.textLabel?.text = item.title
		cell.detailTextLabel?.text = item.url?.absoluteString
		cell.detailTextLabel?.textColor = .darkGray
		return cell
	}

}
