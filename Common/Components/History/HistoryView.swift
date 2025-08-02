//
//  HistoryView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 8/1/25.
//

import SwiftUI

struct HistoryView: View {
    @State private var viewModel = ViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(self.viewModel.orderIndices, id: \.self) { index in
                    if !self.viewModel.orders.isEmpty {
                        ItemCard(
                            imageName: self.viewModel.orders[index].cupcakeImageName,
                            name: self.viewModel.orders[index].title,
                            description: self.viewModel.orders[index].description,
                            price: self.viewModel.orders[index].finalPrice
                        )
                        .onScrollVisibilityChange(threshold: 0.8) { isVisible in
                            self.viewModel.fetchMorePages(
                                isVisible: isVisible,
                                index: index
                            )
                        }
                    }
                }
                
                Spinner(currentViewState: self.viewModel.viewState)
            }
            .padding(.horizontal)
        }
        .navigationTitle("History")
        .onAppear {
            self.viewModel.fetchPage()
        }
        .refreshable {
            self.viewModel.refresh()
        }
        .overlay {
            if viewModel.isLoading && viewModel.orders.isEmpty {
                ProgressView()
            }
        }
        .appAlert(alert: self.$viewModel.error) { }
        .toolbarVisibility(.hidden, for: .tabBar)
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
}
