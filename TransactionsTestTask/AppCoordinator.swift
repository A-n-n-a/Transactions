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

    init(window: UIWindow, navigationController: UINavigationController) {  // ✅ Accept navigationController
        self.window = window
        self.navigationController = navigationController
    }

    func start() {
        let walletCoordinator = WalletCoordinator(navigationController: navigationController)
        walletCoordinator.start()

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
