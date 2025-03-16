//
//  InformationLabel.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//

import SwiftUI

struct InformationLabel: View {
    let title: String
    let subtotal: Double
    
    var body: some View {
        LabeledContent(title, value: subtotal, format: .currency(code: "USD"))
    }
    
    init(
        _ subtotal: Double,
        title: String = "Subtotal:"
    ) {
        self.title = title
        self.subtotal = subtotal
    }
}
