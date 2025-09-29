//
//  FilterViewController.swift
//  Tracker
//
//  Created by Мухаммад Махмудов on 26.09.2025.
//

import UIKit

enum TrackerFilter: String, CaseIterable {
    case all = "filter_all"
    case today = "filter_today"
    case completed = "filter_completed"
    case notCompleted = "filter_not_completed"
    
    var localizedTitle: String {
        switch self {
        case .all:
            return NSLocalizedString("filter_all", comment: "Все трекеры")
        case .today:
            return NSLocalizedString("filter_today", comment: "Трекеры на сегодня")
        case .completed:
            return NSLocalizedString("filter_completed", comment: "Завершенные")
        case .notCompleted:
            return NSLocalizedString("filter_not_completed", comment: "Не завершенные")
        }
    }
}

protocol FilterViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilter)
}

final class FilterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: FilterViewControllerDelegate?
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let filters = TrackerFilter.allCases
    var selectedFilter: TrackerFilter = .all
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Фильтры"
        view.backgroundColor = .systemBackground
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell") ?? UITableViewCell(style: .default, reuseIdentifier: "FilterCell")
        
        let filter = filters[indexPath.row]
        cell.textLabel?.text = filter.localizedTitle
        cell.accessoryType = (filter == selectedFilter) ? .checkmark : .none
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filter = filters[indexPath.row]
        selectedFilter = filter
        delegate?.didSelectFilter(filter)
        dismiss(animated: true)
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
