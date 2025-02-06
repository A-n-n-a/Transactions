//
//  WalletCoordinator.swift
//  TransactionsTestTask
//
//  Created by Anna on 2/5/25.
//

import Combine
import Foundation
import UIKit

final class WalletCoordinator {
    private let navigationController: UINavigationController
    private let storageService: StorageService
    private let rateService: RateService
    private var cancellables = Set<AnyCancellable>()

    init(navigationController: UINavigationController, storageService: StorageService, rateService: RateService) {
        self.navigationController = navigationController
        self.storageService = storageService
        self.rateService = rateService
    }

    func start() {
        let walletViewModel = WalletViewModel(storageService: storageService, rateService: rateService)
        let walletVC = WalletViewController(viewModel: walletViewModel)
        
        walletVC.addTransactionPublisher
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.showAddTransactionScreen()
            }
            .store(in: &cancellables)

        navigationController.pushViewController(walletVC, animated: true)
    }
    
    func showAddTransactionScreen() {
        let addTransactionCoordinator = AddTransactionCoordinator(navigationController: navigationController, storageService: storageService)
        addTransactionCoordinator.start()
    }
}
