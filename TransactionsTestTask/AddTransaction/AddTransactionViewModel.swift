//
//  AddTransactionViewModel.swift
//  TransactionsTestTask
//
//  Created by Anna on 2/6/25.
//

import Combine
import Foundation

class AddTransactionViewModel {
    
    @Published var amount: String = ""
    @Published var selectedCategory: TransactionCategory = .groceries
    @Published var isInputValid: Bool = true
    
    private let storageService: StorageService
    private var cancellables = Set<AnyCancellable>()
    let balance: Double
    let allAvailableCategories = TransactionCategory.allCases.filter { $0 != .deposit }
    
    init(storageService: StorageService, balance: Double) {
        self.storageService = storageService
        self.balance = balance
    }
    
    func isTransactionAmountValid(amountString: String?) -> Bool {
        guard let amountString, let amount = Double(amountString) else {
            return false
        }
        let result = balance - amount
        return result >= 0
    }
    
    func addTransaction(amountString: String?) -> AnyPublisher<Void, Error> {
        guard let amountString, let amount = Double(amountString), amount > 0 else {
            isInputValid = false
            return Fail(error: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid amount"])).eraseToAnyPublisher()
        }
        isInputValid = true
        
        return storageService.addTransaction(amount: amount, category: selectedCategory)
            .flatMap { [weak self] in
                self?.updateWalletBalance(amount: amount) ?? Fail(error: NSError(domain: "", code: 0, userInfo: nil)).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func updateWalletBalance(amount: Double) -> AnyPublisher<Void, Error> {
        return storageService.updateWalletBalance(amount: -amount)
    }
}
