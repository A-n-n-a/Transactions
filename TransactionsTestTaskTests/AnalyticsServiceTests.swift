//
//  AnalyticsServiceTests.swift
//  TransactionsTestTaskTests
//
//  Created by Anna on 2/7/25.
//

import XCTest
import Combine
@testable import TransactionsTestTask

final class AnalyticsServiceTests: XCTestCase {
    
    var analyticsService: AnalyticsService!
    var mockRateService: RateService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockRateService = MockRateService()
        analyticsService = AnalyticsServiceImpl(rateService: mockRateService)
        cancellables = []
    }
    
    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }
    
    // MARK: - Test Track Event
    func testTrackEvent() {
        // Given
        let eventName = "TestEvent"
        let parameters: [String: String] = ["key": "value"]
        let expectation = XCTestExpectation(description: "Event is tracked")
        
        // When
        analyticsService.trackEvent(name: eventName, parameters: parameters)
        
        // Then
        var fetchedEvents: [AnalyticsEvent] = []
        analyticsService.fetchEvents(name: eventName, from: nil, to: nil)
            .sink(receiveCompletion: { _ in }, receiveValue: { events in
                fetchedEvents = events
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(fetchedEvents.count, 1, "There should be one event tracked.")
        XCTAssertEqual(fetchedEvents.first?.name, eventName, "Event name should match.")
        XCTAssertEqual(fetchedEvents.first?.parameters, parameters, "Event parameters should match.")
    }
    
    // MARK: - Test Fetch Events by Name
    func testFetchEventsByName() {
        // Given
        let eventName1 = "TestEvent1"
        let eventName2 = "TestEvent2"
        let expectation = XCTestExpectation(description: "Events with specific name are fetched")
        
        analyticsService.trackEvent(name: eventName1, parameters: ["key": "value1"])
        analyticsService.trackEvent(name: eventName2, parameters: ["key": "value2"])
        
        // When
        var fetchedEvents: [AnalyticsEvent] = []
        analyticsService.fetchEvents(name: eventName1, from: nil, to: nil)
            .sink(receiveCompletion: { _ in }, receiveValue: { events in
                fetchedEvents = events
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(fetchedEvents.count, 1, "Only events with the name \(eventName1) should be returned.")
        XCTAssertEqual(fetchedEvents.first?.name, eventName1, "Fetched event name should match.")
    }
    
    // MARK: - Test Fetch Events by Date Range
    func testFetchEventsByDateRange() {
        // Given
        let eventName = "TestEvent"
        let parameters: [String: String] = ["key": "value"]
        let currentDate = Date()
        let earlierDate = currentDate.addingTimeInterval(-3600) // 1 hour earlier
        let laterDate = currentDate.addingTimeInterval(3600) // 1 hour later
        let expectation = XCTestExpectation(description: "Events within date range are fetched")
        
        analyticsService.trackEvent(name: eventName, parameters: parameters)
        
        // When
        var fetchedEvents: [AnalyticsEvent] = []
        analyticsService.fetchEvents(name: eventName, from: earlierDate, to: laterDate)
            .sink(receiveCompletion: { _ in }, receiveValue: { events in
                fetchedEvents = events
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        XCTAssertEqual(fetchedEvents.count, 1, "Only events within the date range should be returned.")
    }
    
    // MARK: - Test Bitcoin Rate Tracking
    func testBitcoinRateTracking() {
        // Given
        let rate = 50000.0
        let expectation = XCTestExpectation(description: "Rate tracking event is logged.")
        
        // When
        if let mockService = mockRateService as? MockRateService {
            mockService.simulateRateChange(newRate: rate)
        }
        
        analyticsService.fetchEvents(name: AnalyticsEvent.Name.btcRate, from: nil, to: nil)
            .sink { events in
                XCTAssertEqual(events.count, 1, "Bitcoin rate event should be tracked.")
                XCTAssertEqual(events.first?.parameters[AnalyticsEvent.Key.rate], "\(rate)", "The rate should be logged correctly.")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
}

