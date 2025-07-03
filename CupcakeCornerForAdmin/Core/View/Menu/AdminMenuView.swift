//
//  AdminMenu.swift
//  CupcakeCornerForAdmin
//
//  Created by Isaque da Silva on 4/16/25.
//

import SwiftUI

struct AdminMenuView: View {
    @State private var isShowingCreateNewCupcake = false
    @Namespace private var plusButtonNamespace
    private let plusButtonID = "PLUS_BUTTON_TRANSITION"
    
    var body: some View {
        NavigationStack {
            MenuView()
                .navigationDestination(for: ReadCupcake.self) { cupcake in
                    CupcakeDetailView(cupcake: cupcake) {
                        
                    }
                }
                .overlay(alignment: .bottomTrailing) {
                    Group {
                        if #available(iOS 26, *) {
                            plusButton
                                .glassEffect()
                        } else {
                            plusButton
                        }
                    }
                    .padding(.trailing)
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

extension AdminMenuView {
    private var plusButton: some View {
        Button {
            self.isShowingCreateNewCupcake = true
        } label: {
            Icon.plus.systemImage
                .resizable(resizingMode: .stretch)
                .scaledToFit()
                .padding(5)
        }
        .frame(maxWidth: 44, maxHeight: 44)
        .matchedTransitionSource(
            id: self.plusButtonID,
            in: self.plusButtonNamespace
        )
    }
}

#Preview {
    AdminMenuView()
}
