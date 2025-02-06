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
    @Published var isAmountValid: Bool = true
    
    private let storageService: StorageService
    private var cancellables = Set<AnyCancellable>()
    
    let allAvailableCategories = TransactionCategory.allCases.filter { $0 != .deposit }
    
    init(storageService: StorageService) {
        self.storageService = storageService
    }
    
    func addTransaction(amountString: String?) -> AnyPublisher<Void, Error> {
        guard let amountString, let amount = Double(amountString), amount > 0 else {
            isAmountValid = false
            return Fail(error: NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid amount"])).eraseToAnyPublisher()
        }
        isAmountValid = true
        
        return storageService.addTransaction(amount: amount, category: selectedCategory)
    }
}
