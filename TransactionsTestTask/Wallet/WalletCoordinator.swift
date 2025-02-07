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
    private let analyticsService: AnalyticsService
    private var cancellables = Set<AnyCancellable>()

    init(navigationController: UINavigationController, storageService: StorageService, rateService: RateService, analyticsService: AnalyticsService) {
        self.navigationController = navigationController
        self.storageService = storageService
        self.rateService = rateService
        self.analyticsService = analyticsService
    }

    func start() {
        let walletViewModel = WalletViewModel(storageService: storageService, rateService: rateService, analyticsService: analyticsService)
        let walletVC = WalletViewController(viewModel: walletViewModel)
        
        walletVC.addTransactionPublisher
            .receive(on: DispatchQueue.main)
            .sink { balance in
                self.showAddTransactionScreen(balance: balance)
            }
            .store(in: &cancellables)

        navigationController.pushViewController(walletVC, animated: true)
    }
    
    func showAddTransactionScreen(balance: Double) {
        let addTransactionCoordinator = AddTransactionCoordinator(navigationController: navigationController, storageService: storageService, analyticsService: analyticsService, balance: balance)
        addTransactionCoordinator.start()
    }
}
