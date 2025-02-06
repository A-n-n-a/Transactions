//
//  ServicesAssembler.swift
//  TransactionsTestTask
//
//

/// Services Assembler is used for Dependency Injection
/// There is an example of a _bad_ services relationship built on `onRateUpdate` callback
/// This kind of relationship must be refactored with a more convenient and reliable approach
///
/// It's ok to move the logging to model/viewModel/interactor/etc when you have 1-2 modules in your app
/// Imagine having rate updates in 20-50 diffent modules
/// Make this logic not depending on any module

import Combine

enum ServicesAssembler {
    
    // MARK: - BitcoinRateService
    
    static let bitcoinRateService: BitcoinRateService = {
        let service = BitcoinRateServiceImpl()
        let analyticsService = Self.analyticsService

        // Subscribe to the rate publisher and log updates
        service.ratePublisher
            .sink { rate in
                analyticsService.trackEvent(
                    name: "bitcoin_rate_update",
                    parameters: ["rate": String(format: "%.2f", rate)]
                )
            }
            .store(in: &cancellables)
        
        return service
    }()
    
    // MARK: - AnalyticsService
    
    static let analyticsService: AnalyticsService = {
        return AnalyticsServiceImpl()
    }()

    // Store Combine subscriptions to avoid premature deallocation
    private static var cancellables = Set<AnyCancellable>()
}
