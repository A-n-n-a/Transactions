//
//  AddTransactionViewModel.swift
//  TransactionsTestTask
//
//  Created by Anna on 2/6/25.
//

import Combine
import Foundation

class AddTransactionViewModel {
    
    // MARK: - Published Properties
    @Published var amount: String = ""
    @Published var selectedCategory: TransactionCategory = .other
    @Published var isAmountValid: Bool = true
    
    private let storageService: StorageService
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(storageService: StorageService) {
        self.storageService = storageService
    }
    
    // MARK: - Add Transaction
    func addTransaction() -> AnyPublisher<Void, Error> {
        // Check if the amount is valid
        guard let amount = Double(amount), amount > 0 else {
            isAmountValid = false
            return Fail(error: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid amount"])).eraseToAnyPublisher()
        }
        isAmountValid = true
        
        return storageService.addTransaction(amount: amount, category: selectedCategory)
    }
}
