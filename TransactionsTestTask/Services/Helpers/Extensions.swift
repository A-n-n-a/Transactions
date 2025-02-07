//
//  Extensions.swift
//  TransactionsTestTask
//
//  Created by Anna on 2/6/25.
//

import Foundation

extension Double {
    
    private static let btcFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 8
        return formatter
    }()
    
    func btcFormatted() -> String {
        return Double.btcFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

extension Date {
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        return formatter
    }()
    
    func getTime() -> String {
        Date.timeFormatter.dateFormat = "HH:mm"
        return Date.timeFormatter.string(from: self)
    }
}
