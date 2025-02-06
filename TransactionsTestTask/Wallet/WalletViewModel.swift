//
//  WalletViewModel.swift
//  TransactionsTestTask
//
//  Created by Anna on 2/5/25.
//

import Foundation
import Combine

final class WalletViewModel {
    
    private let storageService: StorageService
    private let rateService: RateService
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var balance = 0.0
    @Published private(set) var bitcoinRate = 0.0
    @Published private(set) var transactions: [Transaction] = []
    
    init(storageService: StorageService, rateService: RateService) {
        self.storageService = storageService
        self.rateService = rateService
        rateService.fetchRate()
        rateService.ratePublisher
            .assign(to: \.bitcoinRate, on: self)
            .store(in: &cancellables)
    }
    
    func loadTransactions() {
        storageService.fetchTransactions()
            .receive(on: DispatchQueue.main)
            .assign(to: &$transactions)
    }
    
    func addTransaction(amount: Double, category: TransactionCategory) {
        storageService.addTransaction(amount: amount, category: category)
        loadTransactions()
    }
    
    func addFunds(amount: Double) {
        balance += amount
        storageService.addTransaction(amount: amount, category: .deposit)
    }
    
}
