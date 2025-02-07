//
//  TextFieldValidator.swift
//  TransactionsTestTask
//
//  Created by Anna on 2/7/25.
//

import Foundation
import UIKit

class TextFieldValidator: NSObject, UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let currentText = textField.text else { return true }
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        // Handle the leading zero removal logic
        if newText.hasPrefix("0") && !newText.hasPrefix("0.") && newText.count > 1 {
            if string != "." && string != "," && string != "" {
                textField.text = String(newText.dropFirst())
                return false
            }
        }
        
        // Handle comma at the beginning
        if newText.hasPrefix(",") || newText.hasPrefix(".") {
            textField.text = "0\(string)"
            return false
        }
        
        // Handle only one comma (decimal point) in the input. Only one decimal point allowed
        let separatorCount = newText.components(separatedBy: ",").count + newText.components(separatedBy: ".").count - 2
        if separatorCount > 1 {
            return false
        }
        
        // Handle no more than 8 digits after the decimal point
        if let decimalSeparatorRange = newText.range(of: newText.contains(",") ? "," : ".") {
            let digitsAfterDecimal = newText.suffix(from: decimalSeparatorRange.upperBound)
            if digitsAfterDecimal.count > 8 {
                return false
            }
        }
        
        return true
    }
}
