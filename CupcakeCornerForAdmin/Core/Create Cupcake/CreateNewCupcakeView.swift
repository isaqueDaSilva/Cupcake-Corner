//
//  CreateNewCupcakeView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/10/25.
//

import ErrorWrapper
import SwiftUI

struct CreateNewCupcakeView: View {
    var action: (Cupcake) -> Void
    
    @State private var viewModel = ViewModel()
    
    var body: some View {
        EditCupcake(
            pickerItemSelected: $viewModel.pickerItemSelected,
            flavorName: $viewModel.flavor,
            price: $viewModel.price,
            ingredients: $viewModel.ingredients,
            isLoading: $viewModel.isLoading,
            navigationTitle: "Create",
            coverImageData: viewModel.coverImageData
        ) { dismiss in
            viewModel.create { newCupcake in
                action(newCupcake)
                dismiss()
            }
        }
        .errorAlert(error: $viewModel.error) { }
    }
}

#Preview {
    CreateNewCupcakeView { _ in }
}
