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

protocol BitcoinRateService {
    var ratePublisher: AnyPublisher<Double, Never> { get }
    func fetchRate()
}

final class BitcoinRateServiceImpl: BitcoinRateService {
    private let rateSubject = PassthroughSubject<Double, Never>()
    private var cancellables = Set<AnyCancellable>()

    var ratePublisher: AnyPublisher<Double, Never> {
        rateSubject.eraseToAnyPublisher()
    }

    func fetchRate() {
        let url = URL(string: "https://api.coindesk.com/v1/bpi/currentprice.json")!

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: BitcoinRateResponse.self, decoder: JSONDecoder())
            .map { $0.bpi["USD"]?.rateFloat ?? 0.0 }
            .replaceError(with: 0.0)
            .sink { [weak self] newRate in
                self?.rateSubject.send(newRate)
            }
            .store(in: &cancellables)
    }
}

struct BitcoinRateResponse: Decodable {
    let bpi: [String: CurrencyRate]
    
    var usdRate: Double? {
        return bpi["USD"]?.rateFloat
    }
}

struct CurrencyRate: Decodable {
    let rateFloat: Double
    
    enum CodingKeys: String, CodingKey {
        case rateFloat = "rate_float"
    }
}
