//
//  MenuView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import ErrorWrapper
import SwiftUI

struct MenuView: View {
    @Binding var viewModel: MenuViewModel
    
    var body: some View {
        MenuListViewRepresentable(viewModel: $viewModel)
            .ignoresSafeArea()
            .navigationTitle("Menu")
            .overlay {
                OverlayView(
                    isLoading: viewModel.isLoading,
                    isCupcakeListEmpty: viewModel.cupcakes.isEmpty
                )
            }
            .errorAlert(error: $viewModel.error) { }
            .disabled(viewModel.isLoading)
    }
}

#Preview {
    NavigationStack {
        MenuView(viewModel: .constant(.init(isPreview: true)))
    }
}

