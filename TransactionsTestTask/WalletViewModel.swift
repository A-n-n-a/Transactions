//
//  WalletViewModel.swift
//  TransactionsTestTask
//
//  Created by Anna on 2/5/25.
//

import Foundation
import Combine

final class WalletViewModel {
    @Published private(set) var balance: Double = 0.0
    @Published private(set) var bitcoinRate: Double = 0.0
    
    private let rateService: BitcoinRateService
    private let transactionService: TransactionService
    private var cancellables = Set<AnyCancellable>()
    
    @Published var transactions: [Transaction] = []
    
    init(rateService: BitcoinRateService, transactionService: TransactionService) {
        self.rateService = rateService
        self.transactionService = transactionService
        rateService.fetchRate()
        rateService.ratePublisher
            .assign(to: \.bitcoinRate, on: self)
            .store(in: &cancellables)
    }
    
    func loadTransactions() {
        transactionService.fetchTransactions()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] transactions in
                self?.transactions = transactions
            }
            .store(in: &cancellables)
    }
    
    func addTransaction(amount: Double, category: TransactionCategory) {
        transactionService.addTransaction(amount: amount, category: category)
        loadTransactions()
    }
    
    func addFunds(amount: Double) {
        balance += amount
        transactionService.addTransaction(amount: amount, category: .deposit)
    }
    
    // MARK: Private
    
}
