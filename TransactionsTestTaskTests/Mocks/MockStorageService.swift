//
//  MockStorageService.swift
//  TransactionsTestTaskTests
//
//  Created by Anna on 2/7/25.
//

import Foundation
import Combine
@testable import TransactionsTestTask

class MockStorageService: StorageService {
    
    var transactions: [Transaction] = []
    var walletBalance: Double = 1.0
    var bitcoinRate: Double?
    
    var shouldSucceed = true
    
    func fetchTransactions() -> AnyPublisher<[Transaction], Never> {
        return Just(transactions).eraseToAnyPublisher()
    }
    
    func fetchWalletBalance() -> AnyPublisher<Double, Never> {
        return Just(walletBalance).eraseToAnyPublisher()
    }
    
    func addTransaction(amount: Double, category: TransactionCategory) -> AnyPublisher<Void, Error> {
        guard shouldSucceed else {
            return Fail(error: NSError(domain: "", code: 0, userInfo: nil)).eraseToAnyPublisher()
        }
        
        let transaction = Transaction(amount: amount, category: category, date: Date())
        transactions.append(transaction)
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func updateWalletBalance(amount: Double) -> AnyPublisher<Void, Error> {
        guard shouldSucceed else {
            return Fail(error: NSError(domain: "", code: 0, userInfo: nil)).eraseToAnyPublisher()
        }
        
        walletBalance += amount
        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func saveBitcoinRate(_ rate: Double) {
        bitcoinRate = rate
    }
    
    func getLastBitcoinRate() -> Double? {
        return bitcoinRate
    }
}
