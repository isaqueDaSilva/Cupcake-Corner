//
//  AdminMenu.swift
//  CupcakeCornerForAdmin
//
//  Created by Isaque da Silva on 4/16/25.
//

import SwiftUI

struct AdminMenuView: View {
    @State private var viewModel = MenuViewModel()
    @State private var isShowingCreateNewCupcake = false
    @Namespace private var plusButtonNamespace
    private let plusButtonID = "PLUS_BUTTON_TRANSITION"
    
    var body: some View {
        NavigationStack {
            MenuView(viewModel: $viewModel)
                .navigationDestination(for: ReadCupcake.self) { cupcake in
                    CupcakeDetailView(cupcake: cupcake) { action in
                        switch action {
                        case .update(let updatedCupcake):
                            self.viewModel.cupcakes.updateValue(
                                updatedCupcake,
                                forKey: updatedCupcake.id
                            )
                        case .delete(let cupcakeID):
                            self.viewModel.cupcakes.removeValue(forKey: cupcakeID)
                        default:
                            break
                        }
                    }
                }
                .toolbar {
                    Button {
                        self.isShowingCreateNewCupcake = true
                    } label: {
                        if #available(iOS 26, *) {
                            Icon.plus.systemImage
                        } else {
                            Icon.plusCircle.systemImage
                        }
                    }
                    .matchedTransitionSource(
                        id: self.plusButtonID,
                        in: self.plusButtonNamespace
                    )
                }
                .sheet(isPresented: $isShowingCreateNewCupcake) {
                    CreateNewCupcakeView { newCupcake in
                        self.viewModel.cupcakes.updateValue(
                            newCupcake,
                            forKey: newCupcake.id
                        )
                    }
                    .navigationTransition(
                        .zoom(
                            sourceID: self.plusButtonID,
                            in: self.plusButtonNamespace
                        )
                    )
                }
        }
    }
}

#Preview {
    AdminMenuView()
}
