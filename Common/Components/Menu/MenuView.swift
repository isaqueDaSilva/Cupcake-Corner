//
//  MenuView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import SwiftUI

struct MenuView: View {
    @State private var isOpeningProfileView = false
    @Binding var viewModel: MenuViewModel
    
    var body: some View {
        ZStack {
            if self.viewModel.isLoading && self.viewModel.isCupcakeListEmpty {
                OverlayView(
                    itemName: "Cupcakes",
                    isLoading: viewModel.isLoading,
                    isListEmpty: viewModel.cupcakes.isEmpty
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
        .toolbar {
            Button {
                self.isOpeningProfileView = true
            } label: {
                if #available(iOS 26, *) {
                    Icon.person.systemImage
                } else {
                    Icon.personCircle.systemImage
                        .tint(.blue)
                }
            }

        }
        .sheet(isPresented: $isOpeningProfileView) {
            UserAccountView()
                .environment(UserRepository())
        }
    }
}

extension MenuView {
    private var menuList: some View {
        ScrollView {
            LazyVStack {
                ForEach(self.viewModel.cupcakesIndicies, id: \.self) { index in
                    if !viewModel.cupcakes.isEmpty {
                        NavigationLink(value: viewModel.cupcakes.values.elements[index]) {
                            ItemCard(
                                imageName: viewModel.cupcakes.values.elements[index].imageName,
                                name: viewModel.cupcakes.values.elements[index].flavor,
                                description: viewModel.cupcakes.values.elements[index].description,
                                price: viewModel.cupcakes.values.elements[index].price
                            )
                        }
                        .buttonStyle(.plain)
                        .onScrollVisibilityChange(threshold: 0.8) { isVisible in
                            viewModel.fetchMorePages(isVisible: isVisible, index: index)
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
        MenuView(viewModel: .constant(.init()))
    }
}

