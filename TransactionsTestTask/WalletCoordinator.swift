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

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let rateService = BitcoinRateServiceImpl()
        let transactionService = TransactionServiceImpl(container: CoreDataService.shared.persistentContainer)
        let walletViewModel = WalletViewModel(rateService: rateService, transactionService: transactionService)
        let walletVC = WalletViewController(viewModel: walletViewModel)
        navigationController.pushViewController(walletVC, animated: true)
    }
}
