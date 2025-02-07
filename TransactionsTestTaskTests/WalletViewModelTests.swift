//
//  WalletViewModelTests.swift
//  TransactionsTestTaskTests
//
//  Created by Anna on 2/7/25.
//

import XCTest
import Combine
@testable import TransactionsTestTask

final class WalletViewModelTests: XCTestCase {
    
    private var viewModel: WalletViewModel!
    private var mockStorageService: MockStorageService!
    private var mockRateService: MockRateService!
    private var mockAnalyticsService: MockAnalyticsService!
    private var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockStorageService = MockStorageService()
        mockRateService = MockRateService()
        mockAnalyticsService = MockAnalyticsService()
        cancellables = []
        
        viewModel = WalletViewModel(
            storageService: mockStorageService,
            rateService: mockRateService,
            analyticsService: mockAnalyticsService
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockStorageService = nil
        mockRateService = nil
        mockAnalyticsService = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testLoadBalance() {
        // Given
        mockStorageService.walletBalance = 2.5
        
        // When
        viewModel.loadBalance()
        
        // Then
        XCTAssertEqual(viewModel.balance, 2.5, "Balance should be updated correctly.")
    }
    
    func testLoadTransactions() {
        // Given
        let transaction1 = Transaction(amount: 1.0, category: .groceries, date: Date())
        let transaction2 = Transaction(amount: 0.5, category: .taxi, date: Date().addingTimeInterval(-86400))
        
        mockStorageService.transactions = [transaction1, transaction2]
        
        let expectation = XCTestExpectation(description: "Transactions should be grouped by date")
        
        viewModel.$transactionsByDate
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.loadTransactions()
        
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(viewModel.transactionsByDate.count, 2, "Transactions should be grouped by date.")
        XCTAssertEqual(viewModel.sortedDates.count, 2, "Sorted dates should match transaction count.")
        XCTAssertEqual(mockAnalyticsService.trackedEvents.last?.name, AnalyticsEvent.Name.loadTransactions, "Event should be logged.")
    }
    
    func testAddFunds_Success() {
        
        let depositAmount = 1.0
        mockStorageService.shouldSucceed = true
        let initialBalance = mockStorageService.walletBalance
        
        let expectation = XCTestExpectation(description: "Balance updated successfully")
        
        viewModel.$balance
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { updatedBalance in
                if updatedBalance == initialBalance + depositAmount {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.loadBalance()
        
        viewModel.errorPublisher
            .sink { _ in XCTFail("No error should be sent") }
            .store(in: &cancellables)
        
        viewModel.addFunds(amount: depositAmount)
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(viewModel.balance, initialBalance + depositAmount, "Balance should be equal to 2")
        XCTAssertEqual(mockAnalyticsService.trackedEvents.count, 3, "There should be 3 events logged.")
        XCTAssertEqual(mockAnalyticsService.trackedEvents[0].name, AnalyticsEvent.Name.addDeposit, "First event should be 'add_deposit'.")
        XCTAssertEqual(mockAnalyticsService.trackedEvents[1].name, AnalyticsEvent.Name.loadTransactions, "Second event should be 'load_transactions'.")
        XCTAssertEqual(mockAnalyticsService.trackedEvents[2].name, AnalyticsEvent.Name.updateBalance, "Third event should be 'update_balance'.")
    }
    
    func testAddFunds_Failure() {
        // Given
        mockStorageService.shouldSucceed = false
        let expectation = XCTestExpectation(description: "Error should be sent")
        
        viewModel.errorPublisher
            .sink { error in
                XCTAssertEqual(error, "Error saving deposit", "Error message should be correct.")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.addFunds(amount: 1.0)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testNumberOfSections() {
        // Given
        let transaction = Transaction(amount: 1.0, category: .groceries, date: Date())
        mockStorageService.transactions = [transaction]
        
        let expectation = XCTestExpectation(description: "Transactions should be loaded")
        
        viewModel.$transactionsByDate
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.loadTransactions()
        
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        let sections = viewModel.numberOfSections()
        XCTAssertEqual(sections, 1, "Number of sections should match unique dates.")
    }
    
    func testNumberOfRows() {
        // Given
        let transaction = Transaction(amount: 1.0, category: .groceries, date: Date())
        mockStorageService.transactions = [transaction]
        
        let expectation = XCTestExpectation(description: "Transactions should be loaded")
        
        viewModel.$transactionsByDate
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.loadTransactions()
        
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        let rows = viewModel.numberOfRows(in: 0)
        XCTAssertEqual(rows, 1, "Number of rows should match transactions for the date.")
    }
    
    func testTransactionForIndexPath() {
        // Given
        let transaction = Transaction(amount: 1.0, category: .groceries, date: Date())
        mockStorageService.transactions = [transaction]
        
        let expectation = XCTestExpectation(description: "Transactions should be loaded")
        
        viewModel.$transactionsByDate
            .dropFirst() 
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.loadTransactions()
        
        wait(for: [expectation], timeout: 1.0) // Wait until transactions are loaded
        
        // Then
        let indexPath = IndexPath(row: 0, section: 0)
        let retrievedTransaction = viewModel.transaction(for: indexPath)
        
        XCTAssertEqual(retrievedTransaction.amount, 1.0, "Transaction amount should be correct.")
    }
}
