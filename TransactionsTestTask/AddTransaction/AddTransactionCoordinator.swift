//
//  AddTransactionCoordinator.swift
//  TransactionsTestTask
//
//  Created by Anna on 2/6/25.
//

import Combine
import Foundation
import UIKit

class AddTransactionCoordinator {
    
    private let navigationController: UINavigationController
    private let storageService: StorageService
    private let balance: Double
    private var cancellables = Set<AnyCancellable>()
    
    init(navigationController: UINavigationController, storageService: StorageService, balance: Double) {
        self.navigationController = navigationController
        self.storageService = storageService
        self.balance = balance
    }
    
    func start() {
        let viewModel = AddTransactionViewModel(storageService: storageService, balance: balance)
        let addTransactionVC = AddTransactionViewController(viewModel: viewModel)
        
        addTransactionVC.addTransactionPublisher
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.navigationController.popViewController(animated: true)
            }
            .store(in: &cancellables)
        navigationController.pushViewController(addTransactionVC, animated: true)
    }
}
