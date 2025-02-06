//
//  AddTransactionCoordinator.swift
//  TransactionsTestTask
//
//  Created by Anna on 2/6/25.
//

import Foundation
import UIKit

class AddTransactionCoordinator {
    
    private let navigationController: UINavigationController
    private let storageService: StorageService
    
    // MARK: - Initializer
    init(navigationController: UINavigationController, storageService: StorageService) {
        self.navigationController = navigationController
        self.storageService = storageService
    }
    
    // MARK: - Start
    func start() {
        let viewModel = AddTransactionViewModel(storageService: storageService)
        let addTransactionVC = AddTransactionViewController(viewModel: viewModel)
        //TODO: refactor with Combine
        addTransactionVC.onAddTransaction = {
            self.updateTransactions()
        }
        navigationController.pushViewController(addTransactionVC, animated: true)
    }
    
    // MARK: - Update Transactions
    private func updateTransactions() {
        // Update logic to refresh the data if needed
    }
}
