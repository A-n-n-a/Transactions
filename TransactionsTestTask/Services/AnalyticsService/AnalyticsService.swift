//
//  AnalyticsService.swift
//  TransactionsTestTask
//
//

import Foundation

/// Analytics Service is used for events logging
/// The list of reasonable events is up to you
/// It should be possible not only to track events but to get it from the service
/// The minimal needed filters are: event name and date range
/// The service should be covered by unit tests

import Combine

protocol AnalyticsService {
    func trackEvent(name: String, parameters: [String: String])
    func fetchEvents(name: String?, from startDate: Date?, to endDate: Date?) -> [AnalyticsEvent]
}

final class AnalyticsServiceImpl: AnalyticsService {
    
    private var cancellables = Set<AnyCancellable>()
    private var events: [AnalyticsEvent] = []

    init(rateService: BitcoinRateService? = nil) {
        rateService?.ratePublisher
            .sink { newRate in
                self.trackEvent(name: AnalyticsEvent.Name.btcRate, parameters: [AnalyticsEvent.Key.rate: "\(newRate)"])
            }
            .store(in: &cancellables)
    }

    func trackEvent(name: String, parameters: [String: String]) {
        let event = AnalyticsEvent(
            name: name,
            parameters: parameters,
            date: .now
        )
        events.append(event)
        print("LOG: \(name) - \(parameters)")
    }
    
    func fetchEvents(name: String? = nil, from startDate: Date? = nil, to endDate: Date? = nil) -> [AnalyticsEvent] {
        return events.filter { event in
            var matches = true
            
            // Filter by event name
            if let name = name {
                matches = matches && event.name == name
            }
            
            // Filter by date range
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
