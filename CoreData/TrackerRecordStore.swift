//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Мухаммад Махмудов on 04.09.2025.
//

import CoreData

final class TrackerRecordStore {
    static let shared = TrackerRecordStore()

    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?

    weak var delegate: NSFetchedResultsControllerDelegate? {
        didSet {
            fetchedResultsController?.delegate = delegate
        }
    }
    
    private func normalized(_ date: Date) -> Date { Calendar.current.startOfDay(for: date) }

    private func nextDay(after date: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: 1, to: normalized(date)) ?? normalized(date)
    }

    private init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
        setupFetchedResultsController()
    }

    func fetchAllRecords() throws -> [TrackerRecordCoreData] {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        return try context.fetch(request)
    }

    func addRecord(id: UUID, date: Date, tracker: TrackerCoreData) throws {
        context.performAndWait {
            let record = TrackerRecordCoreData(context: context)
            record.id = id
            record.date = normalized(date)
            record.tracker = tracker
            try? context.save()
        }
    }

    func addRecord(id: UUID, date: Date, tracker: Tracker) throws {
        try context.performAndWait {
            let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
            request.fetchLimit = 1

            guard let trackerCore = try context.fetch(request).first else {
                throw NSError(domain: "TrackerRecordStore", code: 404, userInfo: [NSLocalizedDescriptionKey: "TrackerCoreData not found for id \(tracker.id)"])
            }

            let record = TrackerRecordCoreData(context: context)
            record.id = id
            record.date = normalized(date)
            record.tracker = trackerCore
            try context.save()
        }
    }

    func deleteRecord(_ record: TrackerRecordCoreData) throws {
        try context.performAndWait {
            context.delete(record)
            try context.save()
        }
    }
    private func setupFetchedResultsController() {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController?.delegate = delegate
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Failed to fetch records with NSFetchedResultsController: \(error)")
        }
        normalizeExistingRecordDates()
    }
    
    private func normalizeExistingRecordDates() {
        context.performAndWait {
            let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
            if let records = try? context.fetch(request) {
                var changed = false
                for r in records {
                    let start = Calendar.current.startOfDay(for: r.date ?? Date())
                    if r.date != start {
                        r.date = start
                        changed = true
                    }
                }
                if changed { try? context.save() }
            }
        }
    }
// MARK: - Public Fetch Helpers
func records() -> [TrackerRecord] {
    var result: [TrackerRecord] = []
    context.performAndWait {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        if let fetched = try? context.fetch(request) {
            result = fetched.compactMap { core in
                guard let id = core.id, let trackerId = core.tracker?.id, let date = core.date else { return nil }
                return TrackerRecord(id: id, date: date, trackerID: trackerId)
            }
        }
    }
    return result
}

func records(for trackerID: UUID) -> [TrackerRecord] {
    var result: [TrackerRecord] = []
    context.performAndWait {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "tracker.id == %@", trackerID as CVarArg)
        if let fetched = try? context.fetch(request) {
            result = fetched.compactMap { core in
                guard let id = core.id, let date = core.date else { return nil }
                return TrackerRecord(id: id, date: date, trackerID: trackerID)
            }
        }
    }
    return result
}

func hasRecord(for trackerID: UUID, on date: Date) -> Bool {
    var exists = false
    context.performAndWait {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let start = normalized(date)
        let end = nextDay(after: date)
        request.predicate = NSPredicate(format: "tracker.id == %@ AND date >= %@ AND date < %@", trackerID as CVarArg, start as NSDate, end as NSDate)
        request.fetchLimit = 1
        exists = ((try? context.fetch(request).isEmpty) == false)
    }
    return exists
}

func deleteRecord(trackerID: UUID, on date: Date) throws {
    try context.performAndWait {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        let start = normalized(date)
        let end = nextDay(after: date)
        request.predicate = NSPredicate(format: "tracker.id == %@ AND date >= %@ AND date < %@", trackerID as CVarArg, start as NSDate, end as NSDate)
        if let found = try context.fetch(request).first {
            context.delete(found)
            try context.save()
        }
    }
}

// MARK: - Convenience: add by trackerID
func addRecord(date: Date, trackerID: UUID) throws {
    try context.performAndWait {
        let req: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        req.predicate = NSPredicate(format: "id == %@", trackerID as CVarArg)
        req.fetchLimit = 1
        guard let core = try context.fetch(req).first else { return }
        let rec = TrackerRecordCoreData(context: context)
        rec.id = UUID()
        rec.date = normalized(date)
        rec.tracker = core
        try context.save()
    }
}

// MARK: - Toggle record (create/delete) for a tracker on a day
func toggleRecord(for trackerID: UUID, on date: Date) throws {
    try context.performAndWait {
        let start = normalized(date)
        let end = nextDay(after: date)

        let r: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        r.predicate = NSPredicate(format: "tracker.id == %@ AND date >= %@ AND date < %@", trackerID as CVarArg, start as NSDate, end as NSDate)
        r.fetchLimit = 1
        if let existing = try context.fetch(r).first {
            context.delete(existing)
            try context.save()
            return
        }
        
        let t: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        t.predicate = NSPredicate(format: "id == %@", trackerID as CVarArg)
        t.fetchLimit = 1
        guard let trackerCore = try context.fetch(t).first else { return }

        let rec = TrackerRecordCoreData(context: context)
        rec.id = UUID()
        rec.date = start
        rec.tracker = trackerCore
        try context.save()
    }
}
}
