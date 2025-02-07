//
//  AddTransactionViewController.swift
//  TransactionsTestTask
//
//  Created by Anna on 2/6/25.
//

import Combine
import UIKit

class AddTransactionViewController: UIViewController {
    
    private var viewModel: AddTransactionViewModel
    private var cancellables = Set<AnyCancellable>()
    private let textFieldValidator = TextFieldValidator()
    
    private let addTransactionSubject = PassthroughSubject<Void, Never>()
    var addTransactionPublisher: AnyPublisher<Void, Never> {
        addTransactionSubject.eraseToAnyPublisher()
    }
    
    private let textFieldContainer: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.gray.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let amountTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter amount"
        textField.keyboardType = .decimalPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let categoryPicker: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add Transaction", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .right
        label.textColor = .red
        label.text = "Please enter a valid amount"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(viewModel: AddTransactionViewModel) {
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
    
    private func setupUI() {
        view.backgroundColor = .white
        categoryPicker.dataSource = self
        categoryPicker.delegate = self
        addButton.addTarget(self, action: #selector(addTransactionButtonTapped), for: .touchUpInside)
        amountTextField.delegate = textFieldValidator
        
        view.addSubview(textFieldContainer)
        textFieldContainer.addSubview(amountTextField)
        view.addSubview(categoryPicker)
        view.addSubview(addButton)
        view.addSubview(errorLabel)
        
        NSLayoutConstraint.activate([
            textFieldContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textFieldContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            textFieldContainer.widthAnchor.constraint(equalToConstant: 200),
            textFieldContainer.heightAnchor.constraint(equalToConstant: 50),
            
            amountTextField.leadingAnchor.constraint(equalTo: textFieldContainer.leadingAnchor, constant: 5),
            amountTextField.trailingAnchor.constraint(equalTo: textFieldContainer.trailingAnchor, constant: -5),
            amountTextField.topAnchor.constraint(equalTo: textFieldContainer.topAnchor),
            amountTextField.bottomAnchor.constraint(equalTo: textFieldContainer.bottomAnchor),
            
            categoryPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categoryPicker.topAnchor.constraint(equalTo: textFieldContainer.bottomAnchor, constant: 20),
            
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.topAnchor.constraint(equalTo: categoryPicker.bottomAnchor, constant: 20),
            addButton.widthAnchor.constraint(equalToConstant: 200),
            addButton.heightAnchor.constraint(equalToConstant: 50),
            
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 10)
        ])
    }
    
    private func bindViewModel() {
        
        viewModel.$isAmountValid
            .sink { [weak self] isValid in
                self?.errorLabel.isHidden = isValid
            }
            .store(in: &cancellables)
    }
    
    @objc private func addTransactionButtonTapped() {
        viewModel.addTransaction(amountString: amountTextField.text)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    //TODO: handle error
                    print("Failed to add transaction: \(error.localizedDescription)")
                case .finished:
                    self.addTransactionSubject.send(())
                    self.navigationController?.popViewController(animated: true)
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}

extension AddTransactionViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.allAvailableCategories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.allAvailableCategories[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.selectedCategory = viewModel.allAvailableCategories[row]
    }
}
