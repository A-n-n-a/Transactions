//
//  Rates.swift
//  TransactionsTestTask
//
//  Created by Anna on 2/7/25.
//

import Foundation

struct BitcoinRateResponse: Decodable {
    let bpi: [String: CurrencyRate]
    
    var usdRate: Double? {
        return bpi["USD"]?.rate
    }
}

struct CurrencyRate: Decodable {
    let rate: Double
    
    enum CodingKeys: String, CodingKey {
        case rate = "rate_float"
    }
}
