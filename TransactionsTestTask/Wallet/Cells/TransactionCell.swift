//
//  TransactionCell.swift
//  TransactionsTestTask
//
//  Created by Anna on 2/6/25.
//

import Foundation
import UIKit

class TransactionCell: UITableViewCell {

    private let categoryIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .right
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [categoryIcon, amountLabel, dateLabel])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        
        contentView.addSubview(stack)
        

        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            categoryIcon.widthAnchor.constraint(equalToConstant: 20)
        ])
    }

    func configure(with transaction: Transaction) {
        categoryIcon.image = transaction.category.icon
        let sign = transaction.category == .deposit ? "+" : "-"
        amountLabel.text = "\(sign)\(transaction.amount.btcFormatted())"
        amountLabel.textColor = transaction.category == .deposit ? .green : .red
        
        dateLabel.text = transaction.date.getTime()
    }
}
