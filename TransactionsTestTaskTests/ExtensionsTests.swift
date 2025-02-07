//
//  ExtensionsTests.swift
//  TransactionsTestTaskTests
//
//  Created by Anna on 2/7/25.
//

import Foundation
@testable import TransactionsTestTask
import XCTest

class ExtensionsTests: XCTestCase {

    func testBtcFormatted() {
        // Given
        let value1: Double = 1234.56789
        let value2: Double = 9876.0
        let value3: Double = 0.123456789

        // When
        let formattedValue1 = value1.btcFormatted()
        let formattedValue2 = value2.btcFormatted()
        let formattedValue3 = value3.btcFormatted()

        // Then
        XCTAssertEqual(formattedValue1, "1,234.56789", "The value should be correctly formatted.")
        XCTAssertEqual(formattedValue2, "9,876", "The value should be correctly formatted without decimals.")
        XCTAssertEqual(formattedValue3, "0.12345679", "The value should be correctly formatted with 8 decimals.")
    }
    
    func testGetTime() {
            // Given
            let date = Calendar.current.date(bySettingHour: 14, minute: 30, second: 0, of: Date())!

            // When
            let timeString = date.getTime()

            // Then
            XCTAssertEqual(timeString, "14:30", "The time should be correctly formatted.")
        }

        func testGetDay() {
            // Given
            let date = Date()

            // When
            let startOfDay = date.getDay()

            // Then
            XCTAssertEqual(Calendar.current.isDate(startOfDay, inSameDayAs: date), true, "The start of the day should be correctly computed.")
        }

        func testHeaderFormattedDate() {
            // Given
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

            let date1 = today
            let date2 = yesterday
            let date3 = calendar.date(from: DateComponents(year: 2025, month: 2, day: 1))!

            // When
            let header1 = date1.headerFormattedDate()
            let header2 = date2.headerFormattedDate()
            let header3 = date3.headerFormattedDate()

            // Then
            XCTAssertEqual(header1, "Today", "The date should return 'Today' for today.")
            XCTAssertEqual(header2, "Yesterday", "The date should return 'Yesterday' for yesterday.")
            XCTAssertEqual(header3, "01-02-2025", "The date should return a formatted date for older dates.")
        }
}
