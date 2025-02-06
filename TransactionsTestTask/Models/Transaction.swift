//
//  Transaction.swift
//  TransactionsTestTask
//
//  Created by Anna on 2/5/25.
//


import Foundation

struct Transaction {
    let amount: Double
    let category: TransactionCategory
    let date: Date

    init(entity: TransactionEntity) {
        self.amount = entity.amount
        self.category = TransactionCategory(rawValue: entity.category ?? "other") ?? .other
        self.date = entity.date ?? .now
    }
}

enum TransactionCategory: String, CaseIterable {
    case deposit, groceries, taxi, electronics, restaurant, other
    
    var title: String {
        rawValue.capitalized
    }
}
