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
        tracker.isPinned = false
        try context.save()
    }

    func addTracker(_ tracker: Tracker) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.colorHex = tracker.color.toHexString()
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule.joined(separator: ",")
        let category = fetchOrCreateCategory(named: tracker.categoryName)
        trackerCoreData.category = category
        trackerCoreData.isPinned = false
        try context.save()
    }

    func deleteTracker(_ tracker: TrackerCoreData) throws {
        context.delete(tracker)
        try context.save()
    }

    func deleteTracker(id: UUID) throws {
        let recReq: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        recReq.predicate = NSPredicate(format: "tracker.id == %@", id as CVarArg)
        if let records = try? context.fetch(recReq) {
            for r in records { context.delete(r) }
        }
        if let core = fetchTracker(by: id) {
            context.delete(core)
        }
        try context.save()
    }

    func updateTracker(_ tracker: TrackerCoreData, name: String, color: UIColor, emoji: String, schedule: [WeekDay]) throws {
        tracker.name = name
        tracker.colorHex = color.toHexString()
        tracker.emoji = emoji
        tracker.schedule = schedule.map { $0.rawValue }.joined(separator: ",")

        try context.save()
    }

    func updateTracker(_ tracker: Tracker) throws {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        request.fetchLimit = 1
        guard let core = try context.fetch(request).first else { return }

        core.name = tracker.name
        core.colorHex = tracker.color.toHexString()
        core.emoji = tracker.emoji
        core.schedule = tracker.schedule.joined(separator: ",")

        if core.category?.name != tracker.categoryName {
            let category = fetchOrCreateCategory(named: tracker.categoryName)
            core.category = category
        }

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

    // MARK: - Fetched Results Controller Helpers

    func performInitialFetch() throws {
        try fetchedResultsController.performFetch()
    }

    var fetchedTrackers: [TrackerCoreData] {
        return fetchedResultsController.fetchedObjects ?? []
    }

    var fetchedTrackersModel: [Tracker] {
        return fetchedTrackers.compactMap { makeTracker(from: $0) }
    }
    
    func fetchedTrackersGroupedByCategory() -> [String: [Tracker]] {
        let trackers = fetchedTrackers
        let pinnedCore = trackers.filter { $0.isPinned }
        let regularCore = trackers.filter { !$0.isPinned }
        let pinned = pinnedCore.compactMap { makeTracker(from: $0) }
        let regular = regularCore.compactMap { makeTracker(from: $0) }
        var grouped = Dictionary(grouping: regular) { $0.categoryName }
        if !pinned.isEmpty {
            grouped["Закрепленные"] = pinned
        }
        return grouped
    }

    private func fetchTracker(by id: UUID) -> TrackerCoreData? {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    func isPinned(_ id: UUID) -> Bool {
        return fetchTracker(by: id)?.isPinned ?? false
    }

    func togglePinned(_ id: UUID) throws {
        guard let core = fetchTracker(by: id) else { return }
        core.isPinned.toggle()
        try context.save()
    }

    func setPinned(_ id: UUID, _ value: Bool) throws {
        guard let core = fetchTracker(by: id) else { return }
        core.isPinned = value
        try context.save()
    }

    private func fetchOrCreateCategory(named name: String) -> TrackerCategoryCoreData {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)

        if let existing = try? context.fetch(request).first {
            return existing
        }

        let newCategory = TrackerCategoryCoreData(context: context)
        newCategory.name = name
        return newCategory
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
