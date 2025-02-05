//
//  WalletViewController.swift
//  TransactionsTestTask
//
//

import UIKit
import Combine

class WalletViewController: UIViewController {

    private let viewModel: WalletViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: WalletViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
