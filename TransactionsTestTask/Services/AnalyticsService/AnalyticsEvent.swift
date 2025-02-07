//
//  AnalyticsEvent.swift
//  TransactionsTestTask
//
//

import Foundation

struct AnalyticsEvent {
    
    let name: String
    let parameters: [String: String]
    let date: Date
    
    enum Name {
        static var btcRate = "bitcoin_rate_update"
        static var loadTransactions = "load_transactions"
        static var addTransaction = "add_transaction"
        static var addDeposit = "add_deposit"
        static var updateBalance = "update_balance"
    }
    
    enum Key {
        static var rate = "rate"
        static var category = "category"
        static var amount = "amount"
        static var page = "page"
        static var limit = "limit"
    }
}
