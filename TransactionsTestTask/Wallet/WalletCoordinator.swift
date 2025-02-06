//
//  WalletCoordinator.swift
//  TransactionsTestTask
//
//  Created by Anna on 2/5/25.
//

import Foundation
import UIKit

final class WalletCoordinator {
    private let navigationController: UINavigationController
    private let storageService: StorageService
    private let rateService: RateService

    init(navigationController: UINavigationController, storageService: StorageService, rateService: RateService) {
        self.navigationController = navigationController
        self.storageService = storageService
        self.rateService = rateService
    }

    func start() {
        let walletViewModel = WalletViewModel(storageService: storageService, rateService: rateService)
        let walletVC = WalletViewController(viewModel: walletViewModel)
        navigationController.pushViewController(walletVC, animated: true)
    }
}
