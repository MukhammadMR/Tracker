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

    private init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
        setupFetchedResultsController()
    }

    func fetchAllRecords() throws -> [TrackerRecordCoreData] {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        return try context.fetch(request)
    }

    func addRecord(id: UUID, date: Date, tracker: TrackerCoreData) throws {
        let record = TrackerRecordCoreData(context: context)
        record.id = id
        record.date = date
        record.tracker = tracker
        try context.save()
    }

    func deleteRecord(_ record: TrackerRecordCoreData) throws {
        context.delete(record)
        try context.save()
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
    }
}
