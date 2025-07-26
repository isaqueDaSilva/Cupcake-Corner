//
//  CreateNewCupcakeView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/10/25.
//

import SwiftUI

struct CreateNewCupcakeView: View {
    @State private var viewModel = ViewModel()
    @State private var imageHandler = ImageHandler()
    var action: (ReadCupcake) -> Void
    
    var body: some View {
        EditCupcake(
            pickerItemSelected: $imageHandler.pickerItemSelected,
            cupcakeImage: $imageHandler.cupcakeImage,
            insertCupcakeImageState: $imageHandler.insertState,
            flavorName: $viewModel.newCupcake.flavor,
            price: $viewModel.newCupcake.price,
            ingredients: $viewModel.newCupcake.ingredients,
            isLoading: $viewModel.isLoading,
            navigationTitle: "Create"
        ) { dismiss in
            viewModel.create { cupcakeID, token, session in
                try await imageHandler.sendImage(
                    with: cupcakeID,
                    token: token,
                    and: session
                )
            } action: { newCupcake in
                self.action(newCupcake)
                dismiss()
            }

        }
        .errorAlert(error: $viewModel.error) { }
    }
}

#Preview {
    CreateNewCupcakeView { _ in }
}
