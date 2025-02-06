//
//  TransactionService.swift
//  TransactionsTestTask
//
//  Created by Anna on 2/5/25.
//

import Foundation
import CoreData
import Combine

protocol TransactionService {
    func addTransaction(amount: Double, category: TransactionCategory)
    func fetchTransactions() -> AnyPublisher<[Transaction], Never>
}

final class TransactionServiceImpl: TransactionService {

    private let persistentContainer: NSPersistentContainer

    init(container: NSPersistentContainer) {
        self.persistentContainer = container
    }

    func addTransaction(amount: Double, category: TransactionCategory) {
        let context = persistentContainer.viewContext
        let transaction = TransactionEntity(context: context)
        transaction.amount = amount
        transaction.category = category.rawValue
        transaction.date = Date()

        do {
            try context.save()
        } catch {
            print("Failed to save transaction: \(error)")
        }
    }

    func fetchTransactions() -> AnyPublisher<[Transaction], Never> {
        let context = persistentContainer.viewContext
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
}
