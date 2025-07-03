//
//  OverlayView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 4/16/25.
//

import SwiftUI

struct OverlayView: View {
    let isLoading: Bool
    let isCupcakeListEmpty: Bool
    
    var body: some View {
        Group {
            switch isLoading {
            case true:
                ProgressView()
            case false:
                if isCupcakeListEmpty {
                    EmptyStateView(
                        title: "No Cupcake Load",
                        description: "There are no cupcakes to be displayed.",
                        icon: .magnifyingglass
                    )
                }
            }
        }
    }
}
