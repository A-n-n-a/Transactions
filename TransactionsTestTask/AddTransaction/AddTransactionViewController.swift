//
//  AddTransactionViewController.swift
//  TransactionsTestTask
//
//  Created by Anna on 2/6/25.
//

import Combine
import UIKit

class AddTransactionViewController: UIViewController {
    
    // MARK: - Properties
    private var viewModel: AddTransactionViewModel
    private var cancellables = Set<AnyCancellable>()
    
    var onAddTransaction: (() -> Void)?
    
    // UI Elements
    private let amountTextField = UITextField()
    private let categoryPicker = UIPickerView()
    private let addButton = UIButton(type: .system)
    private let errorLabel = UILabel()

    // MARK: - Initializer
    init(viewModel: AddTransactionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        
        // Amount TextField
        amountTextField.placeholder = "Enter amount"
        amountTextField.keyboardType = .decimalPad
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(amountTextField)
        
        // Category Picker
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        categoryPicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(categoryPicker)
        
        // Add Button
        addButton.setTitle("Add Transaction", for: .normal)
        addButton.addTarget(self, action: #selector(addTransactionButtonTapped), for: .touchUpInside)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButton)
        
        // Error Label
        errorLabel.textColor = .red
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(errorLabel)
        
        // Layout Constraints
        NSLayoutConstraint.activate([
            amountTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            amountTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            amountTextField.widthAnchor.constraint(equalToConstant: 200),
            
            categoryPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categoryPicker.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 20),
            
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.topAnchor.constraint(equalTo: categoryPicker.bottomAnchor, constant: 20),
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 10)
        ])
    }
    
    // MARK: - Bind ViewModel
    private func bindViewModel() {
        // Bind the amount text field to the ViewModel's amount property
        amountTextField
            .publisher(for: \.text)
            .compactMap { $0 }
            .assign(to: \.amount, on: viewModel)
            .store(in: &cancellables)
        
        // Update UI when the amount validity changes
        viewModel.$isAmountValid
            .sink { [weak self] isValid in
                self?.errorLabel.isHidden = isValid
                self?.errorLabel.text = isValid ? "" : "Please enter a valid amount"
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Add Transaction Action
    @objc private func addTransactionButtonTapped() {
        viewModel.addTransaction()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Failed to add transaction: \(error.localizedDescription)")
                case .finished:
                    self.onAddTransaction?()
                    self.navigationController?.popViewController(animated: true)
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}

extension AddTransactionViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    // Number of components in the picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Number of rows in the component
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return TransactionCategory.allCases.count
    }
    
    // Title for each row in the picker view
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return TransactionCategory.allCases[row].rawValue
    }
    
    // Handle selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.selectedCategory = TransactionCategory.allCases[row]
    }
}
