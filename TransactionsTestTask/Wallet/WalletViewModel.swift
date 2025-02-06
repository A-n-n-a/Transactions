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
        loadBalance()
        rateService.fetchRate()
        rateService.ratePublisher
            .assign(to: \.bitcoinRate, on: self)
            .store(in: &cancellables)
    }
    
    func loadBalance() {
        storageService.fetchWalletBalance()
            .assign(to: \.balance, on: self)
            .store(in: &cancellables)
    }
    
    func loadTransactions() {
        storageService.fetchTransactions()
            .receive(on: DispatchQueue.main)
            .assign(to: &$transactions)
    }
    
    func addTransaction(amount: Double, category: TransactionCategory) {
        storageService.addTransaction(amount: amount, category: category)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    //TODO: show error alert
                    print("Error saving transaction: \(error)")
                }
            }, receiveValue: { [weak self] in
                self?.loadTransactions()
            })
            .store(in: &cancellables)
    }
    
    func addFunds(amount: Double) {
        storageService.addTransaction(amount: amount, category: .deposit)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    //TODO: show error alert
                    print("Error saving transaction: \(error)")
                }
            }, receiveValue: { [weak self] in
                self?.loadTransactions()
                self?.balance += amount
                self?.updateWalletBalance(amount: amount)
            })
            .store(in: &cancellables)
    }
    
    func updateWalletBalance(amount: Double) {
        storageService.updateWalletBalance(amount: amount)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    //TODO: show error alert
                    print("Error saving transaction: \(error)")
                }
            }, receiveValue: {// [weak self] in
//                self?.loadTransactions()
                
            })
            .store(in: &cancellables)
    }
}
