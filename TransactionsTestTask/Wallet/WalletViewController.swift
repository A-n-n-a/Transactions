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
    private let textFieldValidator = TextFieldValidator()
    
    private let addTransactionSubject = PassthroughSubject<Double, Never>()
    var addTransactionPublisher: AnyPublisher<Double, Never> {
        addTransactionSubject.eraseToAnyPublisher()
    }
    
    private var balanceTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.text = "Balance:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var balanceLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var labelsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [balanceTitleLabel, balanceLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let bitcoinRateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addFundsButton: UIButton = {
        let button = UIButton()
        button.setTitle("+", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 22
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let addTransactionButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add Transaction", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        viewModel.loadBalance()
        viewModel.loadTransactions()
    }

    private func setupUI() {
        view.backgroundColor = .white
        
        addFundsButton.addTarget(self, action: #selector(didTapAddFunds), for: .touchUpInside)
        addTransactionButton.addTarget(self, action: #selector(didTapAddTransaction), for: .touchUpInside)
        
        tableView.register(TransactionCell.self, forCellReuseIdentifier: "TransactionCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        view.addSubview(labelsStack)
        view.addSubview(bitcoinRateLabel)
        view.addSubview(addFundsButton)
        view.addSubview(addTransactionButton)
        view.addSubview(tableView)
        
        setupConstraints()
    }

    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            labelsStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            labelsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            labelsStack.widthAnchor.constraint(equalToConstant: 250),
            
            bitcoinRateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            bitcoinRateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            addFundsButton.leadingAnchor.constraint(equalTo: labelsStack.trailingAnchor, constant: 10),
            addFundsButton.centerYAnchor.constraint(equalTo: labelsStack.centerYAnchor),
            addFundsButton.heightAnchor.constraint(equalToConstant: 44),
            addFundsButton.widthAnchor.constraint(equalToConstant: 44),
            
            addTransactionButton.topAnchor.constraint(equalTo: labelsStack.bottomAnchor, constant: 20),
            addTransactionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addTransactionButton.widthAnchor.constraint(equalToConstant: 200),
            addTransactionButton.heightAnchor.constraint(equalToConstant: 50),
            
            tableView.topAnchor.constraint(equalTo: addTransactionButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func bindViewModel() {
        viewModel.$balance
            .receive(on: DispatchQueue.main)
            .sink { [weak self] balance in
                self?.balanceLabel.text = "\(balance.btcFormatted()) BTC"
            }
            .store(in: &cancellables)

        viewModel.$bitcoinRate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] rate in
                self?.bitcoinRateLabel.text = String(format: "%.2f USD", rate)
            }
            .store(in: &cancellables)

        viewModel.$transactionsByDate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    
    @objc private func didTapAddFunds() {
        let alert = UIAlertController(title: "Add Funds", message: "Enter the amount of BTC to add", preferredStyle: .alert)
        alert.addTextField { [weak self] textField in
            textField.keyboardType = .decimalPad
            textField.delegate = self?.textFieldValidator
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if let text = alert.textFields?.first?.text, let amount = Double(text), amount != 0 {
                self?.viewModel.addFunds(amount: amount)
            }
        }
        alert.addAction(addAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    @objc private func didTapAddTransaction() {
        addTransactionSubject.send((viewModel.balance))
    }
}

extension WalletViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionCell
        let transaction = viewModel.transaction(for: indexPath)
        cell.configure(with: transaction)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForHeader(in: section)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
