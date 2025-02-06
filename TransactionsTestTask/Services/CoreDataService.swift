//
//  CoreDataService.swift
//  TransactionsTestTask
//
//  Created by Anna on 2/5/25.
//

import Combine
import CoreData
import Foundation

protocol StorageService {
    func fetchTransactions() -> AnyPublisher<[Transaction], Never>
    func addTransaction(amount: Double, category: TransactionCategory)
}

final class CoreDataService: StorageService {
    
    private let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "TransactionsTestTask")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error loading Core Data service: \(error.localizedDescription)")
            }
        }
    }

    var context: NSManagedObjectContext {
        container.viewContext
    }
    
    func fetchTransactions() -> AnyPublisher<[Transaction], Never> {
        
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        do {
            let result = try context.fetch(request)
            let transactions = result.map { Transaction(entity: $0) }
            return Just(transactions).eraseToAnyPublisher()
        } catch {
            print("Failed to fetch transactions: \(error)")
            return Just([]).eraseToAnyPublisher()
        }
    }
    
    func addTransaction(amount: Double, category: TransactionCategory) {
        
        let transaction = TransactionEntity(context: context)
        transaction.amount = amount
        transaction.category = category.rawValue
        transaction.date = .now

        do {
            try context.save()
        } catch {
            print("Failed to save transaction: \(error)")
        }
    }

    
}
