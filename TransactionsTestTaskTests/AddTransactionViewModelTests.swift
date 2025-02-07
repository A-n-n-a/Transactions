//
//  AddTransactionViewModelTests.swift
//  TransactionsTestTaskTests
//
//  Created by Anna on 2/7/25.
//

import XCTest
import Combine
@testable import TransactionsTestTask

class AddTransactionViewModelTests: XCTestCase {
    
    var viewModel: AddTransactionViewModel!
    var mockStorageService: MockStorageService!
    var mockAnalyticsService: MockAnalyticsService!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        mockStorageService = MockStorageService()
        mockAnalyticsService = MockAnalyticsService()
        viewModel = AddTransactionViewModel(
            storageService: mockStorageService,
            analyticsService: mockAnalyticsService,
            balance: 1.0 
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockStorageService = nil
        mockAnalyticsService = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    func test_IsTransactionAmountValid_WhenAmountIsValid_ShouldReturnTrue() {
        XCTAssertTrue(viewModel.isTransactionAmountValid(amountString: "0.5"))
    }
    
    func test_IsTransactionAmountValid_WhenAmountExceedsBalance_ShouldReturnFalse() {
        XCTAssertFalse(viewModel.isTransactionAmountValid(amountString: "1.5"))
    }
    
    func test_IsTransactionAmountValid_WhenAmountIsInvalid_ShouldReturnFalse() {
        XCTAssertFalse(viewModel.isTransactionAmountValid(amountString: "abc"))
        XCTAssertFalse(viewModel.isTransactionAmountValid(amountString: ""))
        XCTAssertFalse(viewModel.isTransactionAmountValid(amountString: nil))
    }
    
    func test_AddTransaction_WhenAmountIsValid_ShouldSucceed() {
        let expectation = self.expectation(description: "Transaction should be added successfully")
        
        mockStorageService.shouldSucceed = true
        viewModel.addTransaction(amountString: "0.5")
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    XCTFail("Expected success but got failure")
                }
                expectation.fulfill()
            }, receiveValue: { })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_AddTransaction_WhenAmountIsInvalid_ShouldFail() {
        let expectation = self.expectation(description: "Transaction should fail due to invalid amount")
        
        viewModel.addTransaction(amountString: "abc")
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    expectation.fulfill()
                } else {
                    XCTFail("Expected failure but got success")
                }
            }, receiveValue: { })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_AddTransaction_WhenStorageFails_ShouldFail() {
        let expectation = self.expectation(description: "Transaction should fail due to storage service failure")
        
        mockStorageService.shouldSucceed = false
        viewModel.addTransaction(amountString: "0.5")
            .sink(receiveCompletion: { completion in
                if case .failure = completion {
                    expectation.fulfill()
                } else {
                    XCTFail("Expected failure but got success")
                }
            }, receiveValue: { })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_AddTransaction_ShouldTrackAnalyticsEvent() {
        viewModel.addTransaction(amountString: "0.5")
            .sink(receiveCompletion: { _ in }, receiveValue: { })
            .store(in: &cancellables)
        
        XCTAssertEqual(mockAnalyticsService.trackedEvents.count, 2)
        XCTAssertEqual(mockAnalyticsService.trackedEvents.first?.name, AnalyticsEvent.Name.addTransaction)
    }
}
