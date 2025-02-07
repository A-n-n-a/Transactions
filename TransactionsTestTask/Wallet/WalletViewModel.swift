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
    private let analyticsService: AnalyticsService
    private var cancellables = Set<AnyCancellable>()
    private(set) var sortedDates: [Date] = []
    private var currentPage = 0
    private let itemsPerPage = 20
    private var allowedLoadTransactions = true
    
    @Published private(set) var balance = 0.0
    @Published private(set) var bitcoinRate = 0.0
    @Published private(set) var transactionsByDate: [Date: [Transaction]] = [:]
    
    private let errorSubject = PassthroughSubject<String, Never>()
    var errorPublisher: AnyPublisher<String, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    init(storageService: StorageService, rateService: RateService, analyticsService: AnalyticsService) {
        self.storageService = storageService
        self.rateService = rateService
        self.analyticsService = analyticsService
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
        
        guard allowedLoadTransactions else { return }
        
        trackEvent(name: AnalyticsEvent.Name.loadTransactions, parameters: [AnalyticsEvent.Key.page: String(currentPage), AnalyticsEvent.Key.limit: String(itemsPerPage)])
        
        storageService.fetchTransactions(page: currentPage, limit: itemsPerPage)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] transactions in
                guard let self = self else { return }
                
                if transactions.isEmpty {
                    allowedLoadTransactions = false
                }
                
                let groupedTransactions = Dictionary(grouping: transactions) { transaction in
                    return transaction.date.getDay()
                }
                
                for (date, transactionsForDate) in groupedTransactions {
                    if var existingTransactions = self.transactionsByDate[date] {
                        existingTransactions.append(contentsOf: transactionsForDate)
                        self.transactionsByDate[date] = existingTransactions
                    } else {
                        self.transactionsByDate[date] = transactionsForDate
                    }
                }
                
                let newDates = groupedTransactions.keys
                self.sortedDates.append(contentsOf: newDates)
                self.sortedDates = Array(Set(self.sortedDates)).sorted(by: >)
                
                self.currentPage += 1
            }
            .store(in: &cancellables)
    }
    
    func addFunds(amount: Double) {
        resetPagination()
        
        trackEvent(name: AnalyticsEvent.Name.addDeposit, parameters: [AnalyticsEvent.Key.amount: amount.btcFormatted()])
        
        storageService.addTransaction(amount: amount, category: .deposit)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(_) = completion {
                    self?.errorSubject.send("Error saving deposit")
                }
            }, receiveValue: { [weak self] in
                self?.loadTransactions()
                self?.balance += amount
                self?.updateWalletBalance(amount: amount)
            })
            .store(in: &cancellables)
    }
    
    func updateWalletBalance(amount: Double) {
        trackEvent(name: AnalyticsEvent.Name.updateBalance, parameters: [AnalyticsEvent.Key.amount: amount.btcFormatted()])
        
        storageService.updateWalletBalance(amount: amount)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorSubject.send("Error updating wallet balance: \(error)")
                }
            }, receiveValue: {})
            .store(in: &cancellables)
    }
    
    func numberOfSections() -> Int {
        return sortedDates.count
    }

    func numberOfRows(in section: Int) -> Int {
        let dateKey = sortedDates[section]
        return transactionsByDate[dateKey]?.count ?? 0
    }
    
    func transaction(for indexPath: IndexPath) -> Transaction {
        let dateKey = sortedDates[indexPath.section]
        return transactionsByDate[dateKey]![indexPath.row]
    }

    func titleForHeader(in section: Int) -> String {
        return sortedDates[section].headerFormattedDate()
    }
    
    func resetPagination() {
        allowedLoadTransactions = true
        currentPage = 0
        transactionsByDate = [:]
        sortedDates = []
    }
    
    private func trackEvent(name: String, parameters: [String: String] = [:]) {
        analyticsService.trackEvent(name: name, parameters: parameters)
    }
}
