//
//  AppCoordinator.swift
//  TransactionsTestTask
//
//  Created by Anna on 2/5/25.
//

import Foundation
import UIKit

final class AppCoordinator {
    
    private let rateService = BitcoinRateServiceImpl()

    init() {
        
    }

    func start() -> UIViewController {
        let viewModel = WalletViewModel()
        return WalletViewController(viewModel: viewModel)
    }
}
