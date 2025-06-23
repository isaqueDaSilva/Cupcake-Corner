//
//  CreateNewCupcakeView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/10/25.
//

import ErrorWrapper
import SwiftUI

struct CreateNewCupcakeView: View {
    @State private var viewModel = ViewModel()
    @State private var imageHandler = ImageHandler()
    
    var body: some View {
        EditCupcake(
            pickerItemSelected: $imageHandler.pickerItemSelected,
            flavorName: $viewModel.newCupcake.flavor,
            price: $viewModel.newCupcake.price,
            ingredients: $viewModel.newCupcake.ingredients,
            isLoading: $viewModel.isLoading,
            navigationTitle: "Create",
            coverImageData: imageHandler.cupcakeImage?.imageData
        ) { dismiss in
            viewModel.create { cupcakeID, token, session in
                try await imageHandler.sendImage(
                    with: cupcakeID,
                    token: token,
                    and: session
                )
            }

        }
        .errorAlert(error: $viewModel.error) { }
    }
}

#Preview {
    CreateNewCupcakeView()
}
