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
    func fetchTransactions() -> AnyPublisher<[String: [Transaction]], Never>
    func fetchWalletBalance() -> AnyPublisher<Double, Never>
    func addTransaction(amount: Double, category: TransactionCategory) -> AnyPublisher<Void, Error>
    func updateWalletBalance(amount: Double) -> AnyPublisher<Void, Error>
    func saveBitcoinRate(_ rate: Double)
    func getLastBitcoinRate() -> Double?
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
    
    //MARK: - Transactions
    func fetchTransactions() -> AnyPublisher<[String: [Transaction]], Never> {
        Future { promise in
            let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

            do {
                let result = try self.context.fetch(request)
                let transactions = result.map { Transaction(entity: $0) }

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy"
                let groupedTransactions = Dictionary(grouping: transactions) { transaction in
                    return dateFormatter.string(from: transaction.date)
                }

                promise(.success(groupedTransactions))
            } catch {
                print("Failed to fetch transactions: \(error)")
                promise(.success([:]))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func addTransaction(amount: Double, category: TransactionCategory) -> AnyPublisher<Void, Error> {
        Future { promise in
            let transaction = TransactionEntity(context: self.context)
            transaction.amount = amount
            transaction.category = category.rawValue
            transaction.date = .now

            do {
                try self.context.save()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    //MARK: - Balance
    func fetchWalletBalance() -> AnyPublisher<Double, Never> {
        Future { promise in
            let request: NSFetchRequest<WalletEntity> = WalletEntity.fetchRequest()

            do {
                let wallets = try self.context.fetch(request)
                let balance = wallets.first?.balance ?? 0.0
                promise(.success(balance))
            } catch {
                print("Failed to fetch wallet balance: \(error)")
                promise(.success(0.0))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func updateWalletBalance(amount: Double) -> AnyPublisher<Void, Error>  {
        Future { promise in
            let request: NSFetchRequest<WalletEntity> = WalletEntity.fetchRequest()
            
            do {
                let wallets = try self.context.fetch(request)
                let wallet: WalletEntity
                
                if let existingWallet = wallets.first {
                    wallet = existingWallet
                } else {
                    wallet = WalletEntity(context: self.context)
                    wallet.balance = 0.0
                }
                
                wallet.balance += amount
                
                try self.context.save()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    //MARK: - Rate
    func saveBitcoinRate(_ rate: Double) {
        let fetchRequest: NSFetchRequest<BitcoinRateEntity> = BitcoinRateEntity.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            let rateEntity: BitcoinRateEntity
            
            if let existingRate = results.first {
                rateEntity = existingRate
            } else {
                rateEntity = BitcoinRateEntity(context: context)
            }
            
            rateEntity.rate = rate
            
            try context.save()
        } catch {
            print("Failed to save Bitcoin rate: \(error)")
        }
    }
    
    func getLastBitcoinRate() -> Double? {
        let fetchRequest: NSFetchRequest<BitcoinRateEntity> = BitcoinRateEntity.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first?.rate
        } catch {
            print("Failed to fetch last Bitcoin rate: \(error)")
            return nil
        }
    }
}
