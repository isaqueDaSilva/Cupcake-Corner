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
                .navigationDestination(for: NavigationInfo.self) { info in
                    CupcakeDetailView(cupcake: info.cupcake) { action in
                        switch action {
                        case .update(let updatedCupcake):
                            self.viewModel.cupcakes.remove(at: info.index)
                            self.viewModel.cupcakes.insert(updatedCupcake, at: info.index)
                        case .delete:
                            self.viewModel.cupcakes.remove(at: info.index)
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
                    // TODO: When this page dismiss fetch the cupcakes again.
                    CreateNewCupcakeView()
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
