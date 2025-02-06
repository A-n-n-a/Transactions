//
//  AppCoordinator.swift
//  TransactionsTestTask
//
//  Created by Anna on 2/5/25.
//

import Foundation
import UIKit

final class AppCoordinator {
    private let window: UIWindow
    private let navigationController: UINavigationController
    private let coreDataService = ServicesAssembler.storageService
    private let bitcoinRateService = ServicesAssembler.bitcoinRateService

    init(window: UIWindow, navigationController: UINavigationController) {
        self.window = window
        self.navigationController = navigationController
    }

    func start() {
        
        let walletCoordinator = WalletCoordinator(navigationController: navigationController, storageService: coreDataService, rateService: bitcoinRateService)
        walletCoordinator.start()

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
