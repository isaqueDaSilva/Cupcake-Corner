//
//  UpdateCupcakeView.swift
//  CupcakeCornerForAdmin
//
//  Created by Isaque da Silva on 3/11/25.
//

import PhotosUI
import SwiftUI

struct UpdateCupcakeView: View {
    @State private var viewModel: ViewModel
    @State private var imageHandler = ImageHandler()
    
    var action: (ReadCupcake?) -> Void
    
    var body: some View {
        EditCupcake(
            pickerItemSelected: $imageHandler.pickerItemSelected,
            cupcakeImage: $imageHandler.cupcakeImage,
            insertCupcakeImageState: $imageHandler.insertState,
            flavorName: $viewModel.flavor,
            price: $viewModel.price,
            ingredients: $viewModel.ingredients,
            isLoading: $viewModel.isLoading,
            navigationTitle: "Update"
        ) { dismiss in
            viewModel.update { cupcakeID, imageName, token in
                try await imageHandler.updateImage(with: cupcakeID, imageName: imageName, token: token)
            } action: { updatedCupcake in
                self.action(updatedCupcake)
                dismiss()
            }


        }
        .appAlert(alert: $viewModel.error) { }
    }
    
    init(cupcake: ReadCupcake, action: @escaping (ReadCupcake?) -> Void) {
        self._viewModel = .init(
            initialValue: .init(cupcake: cupcake)
        )
        self.action = action
    }
}

#if DEBUG
#Preview {
    UpdateCupcakeView(cupcake: .init()) { _ in }
}
#endif
