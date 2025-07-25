//
//  OverlayView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 4/16/25.
//

import SwiftUI

struct OverlayView: View {
    let itemName: String
    let isLoading: Bool
    let isListEmpty: Bool
    
    var body: some View {
        Group {
            switch isLoading {
            case true:
                ProgressView()
            case false:
                if isListEmpty {
                    EmptyStateView(
                        title: "No \(self.itemName) Load",
                        description: "There are no cupcakes to be displayed.",
                        icon: .magnifyingglass
                    )
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}
