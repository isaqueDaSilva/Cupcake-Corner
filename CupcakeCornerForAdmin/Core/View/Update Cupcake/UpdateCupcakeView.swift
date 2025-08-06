//
//  UpdateCupcakeView.swift
//  CupcakeCornerForAdmin
//
//  Created by Isaque da Silva on 3/11/25.
//

import PhotosUI
import SwiftUI

struct UpdateCupcakeView: View {
    @Bindable var accessHandler: AccessHandler
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
            self.viewModel.update(isPerfomingAction: self.accessHandler.isPerfomingAction) { cupcakeID, imageName, token in
                try await imageHandler.updateImage(with: cupcakeID, imageName: imageName, token: token)
            } action: { updatedCupcake in
                self.action(updatedCupcake)
                dismiss()
            }


        }
        .appAlert(alert: $viewModel.error) { }
        .onChange(of: accessHandler.isPerfomingAction) { oldValue, newValue in
            guard newValue, newValue != oldValue && !self.viewModel.executionScheduler.isEmpty else { return }
            
            self.viewModel.executionScheduler[0]()
        }
    }
    
    init(accessHandler: AccessHandler, cupcake: ReadCupcake, action: @escaping (ReadCupcake?) -> Void) {
        self._accessHandler = .init(accessHandler)
        self._viewModel = .init(
            initialValue: .init(cupcake: cupcake)
        )
        self.action = action
    }
}

#if DEBUG
#Preview {
    UpdateCupcakeView(accessHandler: .init(), cupcake: .init()) { _ in }
}
#endif
