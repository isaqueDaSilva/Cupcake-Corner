//
//  CreateNewCupcakeView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/10/25.
//

import SwiftUI

struct CreateNewCupcakeView: View {
    @Environment(AccessHandler.self) var accessHandler
    
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
            self.viewModel.create(isPerfomingAction: self.accessHandler.isPerfomingAction) { cupcakeID, token, session in
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
        .appAlert(alert: $viewModel.error) { }
        .onChange(of: accessHandler.isPerfomingAction) { oldValue, newValue in
            guard newValue, newValue != oldValue && !self.viewModel.executionScheduler.isEmpty else { return }
            
            self.viewModel.executionScheduler[0]()
        }
    }
}

#Preview {
    CreateNewCupcakeView { _ in }
}
