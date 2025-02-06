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
    
    // UI Elements
    private let balanceLabel = UILabel()
    private let bitcoinRateLabel = UILabel()
    private let addFundsButton = UIButton()
    private let addTransactionButton = UIButton()
    private let tableView = UITableView()

    init(viewModel: WalletViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.loadTransactions()
    }

    // Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        
        // Balance Label
        balanceLabel.font = .boldSystemFont(ofSize: 24)
        balanceLabel.textAlignment = .center
        view.addSubview(balanceLabel)
        
        // Bitcoin Rate Label
        bitcoinRateLabel.font = .systemFont(ofSize: 18)
        bitcoinRateLabel.textAlignment = .center
        view.addSubview(bitcoinRateLabel)
        
        // Add Funds Button
        addFundsButton.setTitle("Add Funds", for: .normal)
        addFundsButton.backgroundColor = .systemBlue
        addFundsButton.addTarget(self, action: #selector(didTapAddFunds), for: .touchUpInside)
        view.addSubview(addFundsButton)
        
        // Add Transaction Button
        addTransactionButton.setTitle("Add Transaction", for: .normal)
        addTransactionButton.backgroundColor = .systemGreen
        addTransactionButton.addTarget(self, action: #selector(didTapAddTransaction), for: .touchUpInside)
        view.addSubview(addTransactionButton)
        
        // Transactions TableView
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TransactionCell")
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
        setupConstraints()
    }

    // Layout Constraints
    private func setupConstraints() {
        balanceLabel.translatesAutoresizingMaskIntoConstraints = false
        bitcoinRateLabel.translatesAutoresizingMaskIntoConstraints = false
        addFundsButton.translatesAutoresizingMaskIntoConstraints = false
        addTransactionButton.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            balanceLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            balanceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            bitcoinRateLabel.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor, constant: 10),
            bitcoinRateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addFundsButton.topAnchor.constraint(equalTo: bitcoinRateLabel.bottomAnchor, constant: 20),
            addFundsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addTransactionButton.topAnchor.constraint(equalTo: addFundsButton.bottomAnchor, constant: 20),
            addTransactionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: addTransactionButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // Bind ViewModel to update UI
    private func bindViewModel() {
        viewModel.$balance
            .receive(on: DispatchQueue.main)
            .sink { [weak self] balance in
                self?.balanceLabel.text = "Balance: \(balance) BTC"
            }
            .store(in: &cancellables)

        viewModel.$bitcoinRate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rate in
                self?.bitcoinRateLabel.text = "BTC Rate: \(rate) USD"
            }
            .store(in: &cancellables)

        viewModel.$transactions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] transactions in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    // Actions
    @objc private func didTapAddFunds() {
        let alert = UIAlertController(title: "Add Funds", message: "Enter the amount of BTC to add", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.keyboardType = .decimalPad
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if let text = alert.textFields?.first?.text, let amount = Double(text) {
                self?.viewModel.addFunds(amount: amount)
            }
        }
        alert.addAction(addAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    @objc private func didTapAddTransaction() {
//        let transactionVC = AddTransactionViewController(viewModel: viewModel)
//        navigationController?.pushViewController(transactionVC, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension WalletViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let transaction = viewModel.transactions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)
        cell.textLabel?.text = "\(transaction.category.rawValue) - \(transaction.amount) BTC"
        return cell
    }
}

// MARK: - UITableViewDelegate
extension WalletViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
