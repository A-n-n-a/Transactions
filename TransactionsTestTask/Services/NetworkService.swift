//
//  NetworkService.swift
//  TransactionsTestTask
//
//  Created by Anna on 2/7/25.
//

import Combine
import Foundation

protocol NetworkServiceProtocol {
    func request<T: Decodable>(url: URL) -> AnyPublisher<T, Error>
}

final class NetworkService: NetworkServiceProtocol {
    func request<T: Decodable>(url: URL) -> AnyPublisher<T, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
