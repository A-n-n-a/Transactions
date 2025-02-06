//
//  Extensions.swift
//  TransactionsTestTask
//
//  Created by Anna on 2/6/25.
//

import Foundation

extension Double {
    func btcFormated() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 8
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
