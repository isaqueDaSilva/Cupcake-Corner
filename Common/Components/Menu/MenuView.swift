//
//  MenuView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import SwiftUI

struct MenuView: View {
    @Bindable var viewModel: MenuViewModel
    @Environment(AccessHandler.self) var accessHandler: AccessHandler
    
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
                    index: index,
                    isPerfomingAction: self.accessHandler.isPerfomingAction
                )
            }
        }
        .navigationTitle("Menu")
        .onAppear {
            self.viewModel.fetchPage(isPerfomingAction: self.accessHandler.isPerfomingAction)
        }
        .refreshable {
            self.viewModel.refresh(isPerfomingAction: self.accessHandler.isPerfomingAction)
        }
        .onChange(of: accessHandler.isPerfomingAction) { oldValue, newValue in
            guard newValue, newValue != oldValue && !self.viewModel.executionScheduler.isEmpty else { return }
            
            self.viewModel.executionScheduler[0]()
        }
        .appAlert(alert: self.$viewModel.error) { }
    }
}

#Preview {
    NavigationStack {
        MenuView(viewModel: .init())
    }
}

