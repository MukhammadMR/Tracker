//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Мухаммад Махмудов on 18.08.2025.
//

import UIKit

struct StatisticsItem {
    let value: Int
    let title: String
}

final class StatisticsViewController: UIViewController {
    
    
    private let statistics: [StatisticsItem] = [
        StatisticsItem(value: 6, title: NSLocalizedString("best_period", comment: "Лучший период")),
        StatisticsItem(value: 2, title: NSLocalizedString("perfect_days", comment: "Идеальные дни")),
        StatisticsItem(value: 5, title: NSLocalizedString("trackers_completed", comment: "Трекеров завершено")),
        StatisticsItem(value: 4, title: NSLocalizedString("average_value", comment: "Среднее значение"))
    ]
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistics_title", comment: "Статистика")
        label.font = .boldSystemFont(ofSize: 34)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "error_statistics"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistics_empty", comment: "Анализировать пока нечего")
        label.font = UIFont(name: "YP-Medium", size: 12)
        label.textColor = UIColor(named: "Black day")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var hasStatisticsData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(emptyStateImageView)
        view.addSubview(emptyStateLabel)
        view.addSubview(tableView)
        
        tableView.register(StatisticsCell.self, forCellReuseIdentifier: "StatisticsCell")
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8),
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        updateUI()
    }
    
    private func updateUI() {
        if hasStatisticsData {
            tableView.isHidden = false
            emptyStateImageView.isHidden = true
            emptyStateLabel.isHidden = true
        } else {
            tableView.isHidden = true
            emptyStateImageView.isHidden = false
            emptyStateLabel.isHidden = false
        }
    }
}

extension StatisticsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statistics.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StatisticsCell", for: indexPath) as? StatisticsCell else {
            return UITableViewCell()
        }
        let item = statistics[indexPath.row]
        cell.configure(with: item)
        return cell
    }
}
