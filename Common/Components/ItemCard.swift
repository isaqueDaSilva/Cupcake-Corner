//
//  ItemCard.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//

import SwiftUI

struct ItemCard: View {
    @Environment(AccessHandler.self) private var accessHandler
    private let imageName: String?
    private let name: String
    private let description: String
    private let price: Double
    
    var body: some View {
        GroupBox {
            HStack {
                AsyncCoverImageView(
                    imageName: self.imageName
                )
                .padding(.trailing, 10)
                
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
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    init(
        imageName: String?,
        name: String,
        description: String,
        price: Double
    ) {
        self.imageName = imageName
        self.name = name
        self.description = description
        self.price = price
    }
}

#Preview {
    ItemCard(
        imageName: "",
        name: "Dummy Item",
        description: "Dummy Description",
        price: 5.0
    )
    .padding()
}
