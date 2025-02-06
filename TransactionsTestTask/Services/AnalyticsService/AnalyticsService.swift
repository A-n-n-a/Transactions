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
}

final class AnalyticsServiceImpl: AnalyticsService {
    private var cancellables = Set<AnyCancellable>()

    init(rateService: BitcoinRateService? = nil) {
        rateService?.ratePublisher
            .sink { newRate in
                self.trackEvent(name: "bitcoin_rate_update", parameters: ["rate": "\(newRate)"])
            }
            .store(in: &cancellables)
    }

    func trackEvent(name: String, parameters: [String: String]) {
        print("LOG: \(name) - \(parameters)")
    }
}
//protocol AnalyticsService: AnyObject {
//    
//    func trackEvent(name: String, parameters: [String: String])
//}

//final class AnalyticsServiceImpl {
//    
//    private var events: [AnalyticsEvent] = []
//    
//    // MARK: - Init
//    
//    init() {
//        
//    }
//}

//extension AnalyticsServiceImpl: AnalyticsService {
//    
//    func trackEvent(name: String, parameters: [String: String]) {
//        let event = AnalyticsEvent(
//            name: name,
//            parameters: parameters,
//            date: .now
//        )
//        
//        events.append(event)
//    }
//}
