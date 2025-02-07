//
//  Extensions.swift
//  TransactionsTestTask
//
//  Created by Anna on 2/6/25.
//

import Foundation
import UIKit

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
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        return formatter
    }()
    
    func getTime() -> String {
        Date.dateFormatter.dateFormat = "HH:mm"
        return Date.dateFormatter.string(from: self)
    }
    
    func getDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    func headerFormattedDate() -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else {
            return Date.dateFormatter.string(from: self)
        }

        if calendar.isDate(self, inSameDayAs: today) {
            return "Today"
        } else if calendar.isDate(self, inSameDayAs: yesterday) {
            return "Yesterday"
        } else {
            Date.dateFormatter.dateFormat = "dd-MM-yyyy"
            return Date.dateFormatter.string(from: self)
        }
    }
}

extension UIViewController {
    
    func showErrorAlert(title: String = "Error", message: String, actionTitle: String = "OK", handler: ((UIAlertAction) -> Void)? = nil) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: actionTitle, style: .default, handler: handler)
        alertController.addAction(action)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
