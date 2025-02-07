//
//  MockAnalyticsService.swift
//  TransactionsTestTaskTests
//
//  Created by Anna on 2/7/25.
//

import Foundation
@testable import TransactionsTestTask

class MockAnalyticsService: AnalyticsService {
    
    private(set) var trackedEvents: [AnalyticsEvent] = []
    
    func trackEvent(name: String, parameters: [String: String]) {
        let event = AnalyticsEvent(
            name: name,
            parameters: parameters,
            date: Date()
        )
        trackedEvents.append(event)
    }
    
    func fetchEvents(name: String? = nil, from startDate: Date? = nil, to endDate: Date? = nil) -> [AnalyticsEvent] {
        return trackedEvents.filter { event in
            var matches = true
            
            if let name = name {
                matches = matches && event.name == name
            }
            
            if let startDate = startDate {
                matches = matches && event.date >= startDate
            }
            
            if let endDate = endDate {
                matches = matches && event.date <= endDate
            }
            
            return matches
        }
    }
}
