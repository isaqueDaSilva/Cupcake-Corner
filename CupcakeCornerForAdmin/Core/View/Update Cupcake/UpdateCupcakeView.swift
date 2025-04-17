//
//  UpdateCupcakeView.swift
//  CupcakeCornerForAdmin
//
//  Created by Isaque da Silva on 3/11/25.
//

import ErrorWrapper
import PhotosUI
import SwiftUI

struct UpdateCupcakeView: View {
    @State private var viewModel: ViewModel
    
    var action: (Cupcake) throws -> Void
    
    var body: some View {
        EditCupcake(
            pickerItemSelected: $viewModel.pickerItemSelected,
            flavorName: $viewModel.flavor,
            price: $viewModel.price,
            ingredients: $viewModel.ingredients,
            isLoading: $viewModel.isLoading,
            navigationTitle: "Update",
            coverImageData: viewModel.coverImageData
        ) { dismiss in
            viewModel.update { updatedCupcake in
                try action(updatedCupcake)
                dismiss()
            }
        }
        .errorAlert(error: $viewModel.error) { }
    }
    
    init(cupcake: Cupcake, action: @escaping (Cupcake) throws -> Void) {
        self._viewModel = .init(initialValue: .init(cupcake: cupcake))
        self.action = action
    }
}

#if DEBUG
#Preview {
    UpdateCupcakeView(cupcake: .init()) { _ in }
}
#endif
