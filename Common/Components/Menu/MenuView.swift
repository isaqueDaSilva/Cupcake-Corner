//
//  MenuView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import SwiftUI

struct MenuView: View {
    @Binding var viewModel: MenuViewModel
    
    var body: some View {
        ZStack {
            if self.viewModel.isLoading && self.viewModel.isCupcakeListEmpty {
                OverlayEmptyView(
                    itemName: "Cupcakes",
                    isLoading: self.viewModel.isLoading,
                    isListEmpty: self.viewModel.cupcakes.isEmpty
                )
            }
            
            MenuListView(
                cupcakes: self.viewModel.cupcakes.values.elements,
                currentViewState: self.viewModel.viewState
            ) { isVisible, index in
                self.viewModel.fetchMorePages(
                    isVisible: isVisible,
                    index: index
                )
            }
        }
        .navigationTitle("Menu")
        .onAppear {
            self.viewModel.fetchPage()
        }
        .refreshable {
            self.viewModel.refresh()
        }
        .appAlert(alert: self.$viewModel.error) { }
    }
}

#Preview {
    NavigationStack {
        MenuView(viewModel: .constant(.init()))
    }
}

