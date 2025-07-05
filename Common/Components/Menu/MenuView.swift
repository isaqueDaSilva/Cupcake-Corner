//
//  MenuView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import ErrorWrapper
import SwiftUI

struct MenuView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        ZStack {
            if self.viewModel.isLoading && self.viewModel.isCupcakeListEmpty {
                OverlayView(
                    isLoading: viewModel.isLoading,
                    isCupcakeListEmpty: viewModel.cupcakes.isEmpty
                )
            }
            
            menuList
        }
        .navigationTitle("Menu")
        .onAppear {
            self.viewModel.fetchPage()
        }
        .refreshable {
            self.viewModel.refresh()
        }
        .errorAlert(error: $viewModel.error) { }
    }
}

extension MenuView {
    private var menuList: some View {
        ScrollView {
            VStack {
                ForEach(self.viewModel.cupcakes, id: \.id) { cupcake in
                    NavigationLink(value: cupcake) {
                        ItemCard(
                            imageName: cupcake.imageName,
                            name: cupcake.flavor,
                            description: cupcake.description,
                            price: cupcake.price
                        )
                    }
                    .buttonStyle(.plain)
                    .onScrollVisibilityChange(threshold: 0.8) { isVisible in
                        guard viewModel.viewState != .loadedAll &&
                                !viewModel.isLoading
                        else {
                            return
                        }
                        
                        let eightyPorcentIndex = Int((Double((viewModel.cupcakes.count - 1)) * 0.8).rounded(.up))
                        
                        if isVisible,
                           viewModel.cupcakes.indices.contains(eightyPorcentIndex),
                           cupcake.id == viewModel.cupcakes[eightyPorcentIndex].id {
                            viewModel.fetchMorePages()
                        }
                    }
                }
                
                Group {
                    if viewModel.viewState == .fetchingMore {
                        ProgressView()
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    NavigationStack {
        MenuView()
    }
}

