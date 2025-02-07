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
    }
    
    enum Key {
        static var rate = "rate"
    }
}
