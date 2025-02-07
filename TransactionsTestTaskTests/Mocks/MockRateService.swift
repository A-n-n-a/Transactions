//
//  MockRateService.swift
//  TransactionsTestTaskTests
//
//  Created by Anna on 2/7/25.
//

import Combine
@testable import TransactionsTestTask

class MockRateService: RateService {
    
    private let rateSubject = PassthroughSubject<Double, Never>()
    var ratePublisher: AnyPublisher<Double, Never> {
        rateSubject.eraseToAnyPublisher()
    }
    
    func sendRate(_ rate: Double) {
        rateSubject.send(rate)
    }
}
