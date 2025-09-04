//
//  TrackerStore.swift
//  Tracker
//
//  Created by Мухаммад Махмудов on 04.09.2025.
//

import CoreData
import UIKit

final class TrackerStore: NSObject {
    static let shared = TrackerStore()

    private let context: NSManagedObjectContext

    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        return controller
    }()

    private init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }

    func fetchAllTrackers() throws -> [TrackerCoreData] {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        return try context.fetch(request)
    }

    func addTracker(name: String, color: UIColor, emoji: String, schedule: [WeekDay]) throws {
        let tracker = TrackerCoreData(context: context)
        tracker.id = UUID()
        tracker.name = name
        tracker.colorHex = color.toHexString()
        tracker.emoji = emoji
        tracker.schedule = schedule.map { $0.rawValue }.joined(separator: ",")

        try context.save()
    }

    func deleteTracker(_ tracker: TrackerCoreData) throws {
        context.delete(tracker)
        try context.save()
    }

    func updateTracker(_ tracker: TrackerCoreData, name: String, color: UIColor, emoji: String, schedule: [WeekDay]) throws {
        tracker.name = name
        tracker.colorHex = color.toHexString()
        tracker.emoji = emoji
        tracker.schedule = schedule.map { $0.rawValue }.joined(separator: ",")

        try context.save()
    }

    private func makeTracker(from trackerCoreData: TrackerCoreData) -> Tracker? {
        guard let id = trackerCoreData.id,
              let name = trackerCoreData.name,
              let colorHex = trackerCoreData.colorHex,
              let emoji = trackerCoreData.emoji,
              let scheduleString = trackerCoreData.schedule else {
            return nil
        }

        let schedule = scheduleString
            .split(separator: ",")
            .compactMap { WeekDay(rawValue: String($0)) }

        return Tracker(
            id: id,
            name: name,
            color: UIColor(hex: colorHex),
            emoji: emoji,
            categoryName: trackerCoreData.category?.name ?? "",
            schedule: schedule.map { $0.rawValue }
        )
    }
}

extension UIColor {
    func toHexString() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let rgb: Int = (Int)(red*255)<<16 | (Int)(green*255)<<8 | Int(blue*255)<<0
        return String(format:"#%06x", rgb)
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    }
}
