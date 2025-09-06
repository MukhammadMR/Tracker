//
//  CoreDataStack.swift
//  Tracker
//
//  Created by Мухаммад Махмудов on 04.09.2025.
//

import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

        let persistentContainer: NSPersistentContainer

        var context: NSManagedObjectContext {
            persistentContainer.viewContext
        }

        private init() {
            persistentContainer = NSPersistentContainer(name: "TrackerModel") // имя как у .xcdatamodeld
            persistentContainer.loadPersistentStores { description, error in
                if let error = error {
                    fatalError("Ошибка загрузки хранилища: \(error)")
                }
            }
        }

        func saveContext() {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    fatalError("Ошибка сохранения контекста: \(error)")
                }
            }
        }
}


