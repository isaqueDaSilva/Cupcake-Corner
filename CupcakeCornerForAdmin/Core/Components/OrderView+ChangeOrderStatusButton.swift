//
//  OrderView+ChangeOrderStatusButton.swift
//  CupcakeCornerForAdmin
//
//  Created by Isaque da Silva on 7/24/25.
//

import SwiftUI

struct ChangeOrderStatusButton: View {
    let currentStatus: Status
    var action: () -> Void
    
    var body: some View {
        Button {
            self.action()
        } label: {
            switch self.currentStatus {
            case .ordered:
                Label(
                    "Mark as Ready For Delivery",
                    systemImage: Icon.truck.rawValue
                )
            case .readyForDelivery, .delivered:
                Label(
                    "Mark as Delivered",
                    systemImage: Icon.shippingBox.rawValue
                )
                .disabled(currentStatus == .delivered)
            }
        }
    }
}

#Preview {
    ChangeOrderStatusButton(
        currentStatus: .allCases.randomElement() ?? .readyForDelivery
    ) { }
}
