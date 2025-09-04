//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Мухаммад Махмудов on 04.09.2025.
//
import CoreData

final class TrackerCategoryStore: NSObject {
    static let shared = TrackerCategoryStore()

    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?

    var onChange: () -> Void = {}

    private init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Failed to fetch categories with NSFetchedResultsController: \(error)")
        }
        super.init()
        fetchedResultsController?.delegate = self
    }

    func fetchAllCategories() throws -> [TrackerCategoryCoreData] {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        return try context.fetch(request)
    }

    func addCategory(name: String) throws {
        let category = TrackerCategoryCoreData(context: context)
        category.name = name
        try context.save()
    }

    func deleteCategory(_ category: TrackerCategoryCoreData) throws {
        context.delete(category)
        try context.save()
    }

    func updateCategory(_ category: TrackerCategoryCoreData, name: String) throws {
        category.name = name
        try context.save()
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        onChange()
    }
}
