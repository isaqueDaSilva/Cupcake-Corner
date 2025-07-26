//
//  OverlayEmptyView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 4/16/25.
//

import SwiftUI

struct OverlayEmptyView: View {
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
                    ContentUnavailableView(
                        "No \(self.itemName) Load",
                        systemImage: Icon.magnifyingglass.rawValue,
                        description: Text("There are no cupcakes to be displayed.")
                    )
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}
