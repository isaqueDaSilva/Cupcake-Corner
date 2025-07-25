//
//  OrderListView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 7/25/25.
//

import SwiftUI

struct OrderListView: View {
    let orders: [Order]
    let currentViewState: ViewState
    var paginationAction: (Bool, Int) -> Void
    var updateAction: (Int) -> ()
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(orders.indices, id: \.self) { index in
                    if !orders.isEmpty {
                        ItemCard(
                            imageName: orders[index].cupcakeImageName,
                            name: orders[index].title,
                            description: orders[index].description,
                            price: orders[index].finalPrice
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onScrollVisibilityChange(threshold: 0.8) { isVisible in
                            self.paginationAction(isVisible, index)
                        }
                        #if ADMIN
                        .contextMenu {
                            ChangeOrderStatusButton(
                                currentStatus: self.orders[index].status
                            ) {
                                self.updateAction(index)
                            }
                        }
                        #endif
                        .padding(.horizontal)
                    }
                }
                
                Group {
                    if self.currentViewState == .fetchingMore {
                        ProgressView()
                    }
                }
            }
        }
    }
}

#Preview {
    OrderListView(orders: Order.mocks, currentViewState: .default) { _, _ in} updateAction: { _ in }
}
