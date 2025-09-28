//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Мухаммад Махмудов on 18.08.2025.
//

import UIKit
import CoreData

struct StatisticsItem {
    let value: Int
    let title: String
}

final class StatisticsViewController: UIViewController {
    
    
    private var statistics: [StatisticsItem] = []
    
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
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private func reloadStatistics() {
        var completedCount = 0
        if let context = try? CoreDataStack.shared.context {
            let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
            completedCount = (try? context.count(for: request)) ?? 0
            
            let fetch: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
            let allRecords = (try? context.fetch(fetch)) ?? []
            
            let bestPeriod = calculateBestPeriod(records: allRecords)
            let perfectDays = calculatePerfectDays(records: allRecords)
            let averageValue = calculateAverageValue(records: allRecords)
            
            statistics = [
                StatisticsItem(value: bestPeriod, title: NSLocalizedString("best_period", comment: "Лучший период")),
                StatisticsItem(value: perfectDays, title: NSLocalizedString("perfect_days", comment: "Идеальные дни")),
                StatisticsItem(value: completedCount, title: NSLocalizedString("trackers_completed", comment: "Трекеров завершено")),
                StatisticsItem(value: averageValue, title: NSLocalizedString("average_value", comment: "Среднее значение"))
            ]
        }

        hasStatisticsData = completedCount > 0
        updateUI()
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, item) in statistics.enumerated() {
            let cell = StatisticsCell()
            cell.configure(with: item)
            cell.translatesAutoresizingMaskIntoConstraints = false
            cell.heightAnchor.constraint(equalToConstant: StatisticsCell.cellHeight).isActive = true
            stackView.addArrangedSubview(cell)
        }
    }
    
    private var hasStatisticsData = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(titleLabel)
        view.addSubview(emptyStateImageView)
        view.addSubview(emptyStateLabel)
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 88),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            emptyStateImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 8),
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        reloadStatistics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadStatistics()
    }
    
    private func updateUI() {
        if hasStatisticsData {
            stackView.isHidden = false
            emptyStateImageView.isHidden = true
            emptyStateLabel.isHidden = true
        } else {
            stackView.isHidden = true
            emptyStateImageView.isHidden = false
            emptyStateLabel.isHidden = false
        }
    }
    
    private func calculateBestPeriod(records: [TrackerRecordCoreData]) -> Int {
        let dates = Set(records.compactMap { $0.date?.startOfDay })
        let sorted = dates.sorted()
        var maxStreak = 0
        var currentStreak = 0
        var prevDate: Date?

        for date in sorted {
            if let prev = prevDate, let next = Calendar.current.date(byAdding: .day, value: 1, to: prev), Calendar.current.isDate(next, inSameDayAs: date) {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
            maxStreak = max(maxStreak, currentStreak)
            prevDate = date
        }
        return maxStreak
    }

    private func calculatePerfectDays(records: [TrackerRecordCoreData]) -> Int {
        let grouped = Dictionary(grouping: records) { $0.date?.startOfDay ?? Date() }
        var perfect = 0
        for (day, recs) in grouped {
            let completedTrackers = Set(recs.compactMap { $0.tracker?.id })
            // общее количество активных трекеров
            let activeTrackers = (try? CoreDataStack.shared.context.count(for: TrackerCoreData.fetchRequest())) ?? 0
            if completedTrackers.count == activeTrackers && activeTrackers > 0 {
                perfect += 1
            }
        }
        return perfect
    }

    private func calculateAverageValue(records: [TrackerRecordCoreData]) -> Int {
        let grouped = Dictionary(grouping: records) { $0.date?.startOfDay ?? Date() }
        guard !grouped.isEmpty else { return 0 }
        let total = records.count
        return total / grouped.keys.count
    }
}

private extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}
