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
    private let analyticsService: AnalyticsService
    private var cancellables = Set<AnyCancellable>()
    let balance: Double
    let allAvailableCategories = TransactionCategory.allCases.filter { $0 != .deposit }
    
    init(storageService: StorageService, analyticsService: AnalyticsService, balance: Double) {
        self.storageService = storageService
        self.analyticsService = analyticsService
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
        
        trackEvent(name: AnalyticsEvent.Name.addTransaction, parameters: [AnalyticsEvent.Key.amount: amount.btcFormatted(), AnalyticsEvent.Key.category: selectedCategory.title])
        
        return storageService.addTransaction(amount: amount, category: selectedCategory)
            .flatMap { [weak self] in
                self?.updateWalletBalance(amount: amount) ?? Fail(error: NSError(domain: "", code: 0, userInfo: nil)).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func updateWalletBalance(amount: Double) -> AnyPublisher<Void, Error> {
        trackEvent(name: AnalyticsEvent.Name.updateBalance, parameters: [AnalyticsEvent.Key.amount: (-amount).btcFormatted()])
        
        return storageService.updateWalletBalance(amount: -amount)
    }
    
    private func trackEvent(name: String, parameters: [String: String] = [:]) {
        analyticsService.trackEvent(name: name, parameters: parameters)
    }
}
