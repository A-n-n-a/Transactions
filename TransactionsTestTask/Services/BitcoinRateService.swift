//
//  BitcoinRateService.swift
//  TransactionsTestTask
//
//

/// Rate Service should fetch data from https://api.coindesk.com/v1/bpi/currentprice.json
/// Fetching should be scheduled with dynamic update interval
/// Rate should be cached for the offline mode
/// Every successful fetch should be logged with analytics service
/// The service should be covered by unit tests

import Combine
import Foundation

protocol RateService {
    var ratePublisher: AnyPublisher<Double, Never> { get }
}

final class BitcoinRateService: RateService {
    
    private var cancellables = Set<AnyCancellable>()
    private let networkService: NetworkServiceProtocol
    
    private let rateSubject = PassthroughSubject<Double, Never>()
    var ratePublisher: AnyPublisher<Double, Never> {
        rateSubject.eraseToAnyPublisher()
    }

    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
        fetchRatePeriodically()
    }

    private func fetchRatePeriodically() {
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchRate()
            }
            .store(in: &cancellables)
    }

    private func fetchRate() {
        guard let url = URL(string: "https://api.coindesk.com/v1/bpi/currentprice.json") else { return }

        networkService.request(url: url)
            .map { (response: BitcoinRateResponse) in response.bpi["USD"]?.rate ?? 0.0 }
            .replaceError(with: 0.0)
            .sink { [weak self] newRate in
                self?.rateSubject.send(newRate)
            }
            .store(in: &cancellables)
    }
}
