//
//  ItemCard.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//


import SwiftUI

struct ItemCard: View {
    let name: String
    let description: String
    let price: Double
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Text(name)
                        .font(.headline)
                    
                    Text(price, format: .currency(code: "USD"))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.bottom)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    init(
        name: String,
        description: String,
        price: Double
    ) {
        self.name = name
        self.description = description
        self.price = price
    }
}

#Preview {
    ItemCard(
        name: "Dummy Item",
        description: "Dummy Description",
        price: 5.0
    )
    .padding()
}
