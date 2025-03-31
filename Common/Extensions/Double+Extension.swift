//
//  Double+Extension.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/28/25.
//

import Foundation

extension Double {
    var toCurreny: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        
        guard let currency = formatter.string(for: self) else {
            return "US$ 0.0"
        }
        
        return currency
    }
}
