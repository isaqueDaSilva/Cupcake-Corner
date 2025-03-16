//
//  PaymentMethod.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import Foundation

enum PaymentMethod: String, Codable, CaseIterable, Identifiable, Sendable {
    case cash, creditCard, debitCard
    
    var id: Self { self }
    
    var displayedName: String {
        switch self {
        case .cash:
            "Cash"
        case .creditCard:
            "Credit Card"
        case .debitCard:
            "Debit Crad"
        }
    }
}
