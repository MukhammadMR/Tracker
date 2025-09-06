//
//  TrackerFactory.swift
//  Tracker
//
//  Created by Мухаммад Махмудов on 06.09.2025.
//

import UIKit

struct TrackerFactory {
    static func makeTracker(
        title: String,
        emoji: String?,
        color: UIColor?,
        category: String?,
        schedule: [String]
    ) -> Tracker {
        return Tracker(
            id: UUID(),
            name: title,
            color: color ?? .systemGreen,
            emoji: emoji ?? "😪",
            categoryName: category ?? "Без категории",
            schedule: schedule
        )
    }
}
