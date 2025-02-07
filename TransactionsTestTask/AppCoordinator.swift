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
    private let analyticsService = ServicesAssembler.analyticsService

    init(window: UIWindow, navigationController: UINavigationController) {
        self.window = window
        self.navigationController = navigationController
    }

    func start() {
        
        let walletCoordinator = WalletCoordinator(navigationController: navigationController, storageService: coreDataService, rateService: bitcoinRateService, analyticsService: analyticsService)
        walletCoordinator.start()

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
