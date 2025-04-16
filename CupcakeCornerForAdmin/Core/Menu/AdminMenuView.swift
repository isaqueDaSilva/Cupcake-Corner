//
//  AdminMenu.swift
//  CupcakeCornerForAdmin
//
//  Created by Isaque da Silva on 4/16/25.
//

import SwiftUI

struct AdminMenuView: View {
    var body: some View {
        MenuView()
            .toolbar {
                Button {
                    viewModel.isShowingCreateNewCupcake = true
                } label: {
                    Icon.plusCircle.systemImage
                }
            }
            .sheet(isPresented: $viewModel.isShowingCreateNewCupcake) {
                CreateNewCupcakeView { newCupcake in
                    viewModel.updateStorage(with: .create(newCupcake))
                }
            }
    }
}

#Preview {
    AdminMenu()
}
