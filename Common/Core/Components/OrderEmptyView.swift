//
//  OrderEmptyView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//

import SwiftUI

struct OrderEmptyView: View {
    var body: some View {
        EmptyStateView(
            title: "No orders to display",
            description: "",
            icon: .bag
        )
    }
}
