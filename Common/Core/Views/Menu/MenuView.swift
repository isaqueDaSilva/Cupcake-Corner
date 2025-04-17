//
//  MenuView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import ErrorWrapper
import SwiftUI

struct MenuView: View {
    @Bindable var cupcakeRepository: CupcakeRepository
    @State private var viewModel = ViewModel()
    
    var body: some View {
        MenuList(cupcakeList: cupcakeRepository.cupcakes)
            .onAppear {
                if cupcakeRepository.isCupcakeListEmpty {
                    viewModel.fetch { cupcakeList in
                        cupcakeRepository.fillStorage(
                            with: cupcakeList.cupcakes
                        )
                    }
                }
            }
            .opacity(viewModel.isLoading ? 0 : 1)
            .overlay {
                OverlayView(
                    isLoading: viewModel.isLoading,
                    isCupcakeListEmpty: cupcakeRepository.isCupcakeListEmpty
                )
            }
            .navigationTitle("Menu")
            .errorAlert(error: $viewModel.error) { }
            .refreshable {
                viewModel.fetch { cupcakeList in
                    self.cupcakeRepository.fillStorage(
                        with: cupcakeList.cupcakes
                    )
                }
            }
            .disabled(viewModel.isLoading)
    }
}

#Preview {
    MenuView(cupcakeRepository: .init(isPreview: true))
        .environment(UserRepository())
}

