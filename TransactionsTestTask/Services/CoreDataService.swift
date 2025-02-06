//
//  CoreDataService.swift
//  TransactionsTestTask
//
//  Created by Anna on 2/5/25.
//

import Foundation
import CoreData

final class CoreDataService {
    static let shared = CoreDataService()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TransactionsTestTask")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data service: \(error)")
            }
        }
        return container
    }()

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}
