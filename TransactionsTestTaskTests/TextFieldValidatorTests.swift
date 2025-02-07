//
//  TextFieldValidatorTests.swift
//  TransactionsTestTaskTests
//
//  Created by Anna on 2/7/25.
//

import Foundation
import XCTest
@testable import TransactionsTestTask

class TextFieldValidatorTests: XCTestCase {
    
    var validator: TextFieldValidator!
    var textField: UITextField!
    
    override func setUp() {
        super.setUp()
        validator = TextFieldValidator()
        textField = UITextField()
        textField.delegate = validator
    }
    
    override func tearDown() {
        validator = nil
        textField = nil
        super.tearDown()
    }
    
    // "01" -> "1"
    func testLeadingZeroRemoval() {
        textField.text = "0"
        let result = validator.textField(textField, shouldChangeCharactersIn: NSRange(location: 1, length: 0), replacementString: "1")
        
        XCTAssertFalse(result)
        XCTAssertEqual(textField.text, "1")
    }
    
    // "." -> "0."
    // "," -> "0,"
    func testCommaOrDotAtBeginning() {
        textField.text = ""
        
        let result1 = validator.textField(textField, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: ",")
        
        XCTAssertFalse(result1)
        XCTAssertEqual(textField.text, "0,")
        
        textField.text = ""
        
        let result2 = validator.textField(textField, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: ".")
        XCTAssertFalse(result2)
        XCTAssertEqual(textField.text, "0.")
    }
    
    // Test multiple separators (either comma or dot) in the input
    func testMultipleSeparators() {
        textField.text = "10,20,30"
        let result = validator.textField(textField, shouldChangeCharactersIn: NSRange(location: 7, length: 0), replacementString: ",")
        
        XCTAssertFalse(result)
        XCTAssertEqual(textField.text, "10,20,30")
    }
    
    // Test for allowing only up to 8 digits after the decimal separator
    func testMaxDigitsAfterDecimal() {
        textField.text = "1.23456789"
        
        let result = validator.textField(textField, shouldChangeCharactersIn: NSRange(location: 10, length: 0), replacementString: "1")
        
        XCTAssertFalse(result)
        XCTAssertEqual(textField.text, "1.23456789")
    }
    
}
