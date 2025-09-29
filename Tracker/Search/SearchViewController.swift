//
//  SearchViewController.swift
//  Tracker
//
//  Created by Мухаммад Махмудов on 23.09.2025.
//

import UIKit

final class SearchViewController: UIViewController, UISearchResultsUpdating {

    // MARK: - Properties
    let searchController: UISearchController
    var onSearchTextChanged: ((String) -> Void)?

    // MARK: - Init
    init() {
        let resultsController = nil as UIViewController?
        self.searchController = UISearchController(searchResultsController: resultsController)
        super.init(nibName: nil, bundle: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchResultsUpdater = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        onSearchTextChanged?(searchText)
    }
}
