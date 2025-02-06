//
//  Category.swift
//  TransactionsTestTask
//
//  Created by Anna on 2/6/25.
//

import Foundation
import UIKit

enum TransactionCategory: String, CaseIterable {
    case deposit, groceries, taxi, electronics, restaurant, other
    
    var title: String {
        rawValue.capitalized
    }
    
    var icon: UIImage? {
        switch self {
        case .deposit:
            UIImage(systemName: "arrow.down.circle.fill")
        case .groceries:
            UIImage(systemName: "cart.fill")
        case .taxi:
            UIImage(systemName: "taxi.fill")
        case .electronics:
            UIImage(systemName: "tv.fill")
        case .restaurant:
            UIImage(systemName: "fork.knife")
        case .other:
            UIImage(systemName: "ellipsis.circle.fill")
        }
    }
}
