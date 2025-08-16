//
//  OrderView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/11/25.
//

import SwiftUI

struct OrderView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(AccessHandler.self) private var accessHandler
    @State private var viewModel = ViewModel()
    
    var body: some View {
        
        
        NavigationStack {
            ZStack {
                if self.viewModel.orders.isEmpty {
                    OverlayEmptyView(
                        itemName: "Orders",
                        isLoading: viewModel.isLoading,
                        isListEmpty: viewModel.orders.isEmpty
                    )
                }
                
                VStack {
                    OrderFilterPickerView(
                        filter: $viewModel.statusType
                    )
                    .labelsHidden()
                    .disabled(viewModel.isLoading)
                    
                    OrderListView(
                        orders: self.viewModel.orders,
                        currentViewState: self.viewModel.viewState
                    ) { isVisible, index in
                        self.viewModel.fetchMorePages(
                            isVisible: isVisible,
                            index: index,
                            isPerfomingAction: accessHandler.isPerfomingAction
                        )
                    } updateAction: { index in
                        #if ADMIN
                        self.viewModel.updateOrder(at: index, isPerfomingAction: accessHandler.isPerfomingAction)
                        #endif
                    }

                }
            }
            .navigationTitle("Order")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Group {
                        if viewModel.connectionStatus != .connected {
                            Text(viewModel.connectionStatus.rawValue)
                                .font(.subheadline)
                                .bold()
                        }
                    }
                }
            }
            .onChange(of: scenePhase) { oldValue, newValue in
                if newValue == .background || newValue == .inactive {
                    viewModel.disconnect(
                        isWaitingForDisconnect: true
                    )
                } else if newValue == .active {
                    viewModel.reconnect()
                }
            }
            .onChange(of: self.accessHandler.userProfile) { _, _ in
                if accessHandler.userProfile == nil {
                    viewModel.disconnect(isWaitingForDisconnect: false)
                }
            }
            .onChange(of: self.accessHandler.isPerfomingAction) { oldValue, newValue in
                if oldValue && newValue == false {
                    self.viewModel.connect(isFetchRecords: false)
                    
                    for action in self.viewModel.executionScheduler {
                        action()
                    }
                } else {
                    self.viewModel.disconnect(isWaitingForDisconnect: false)
                }
            }
            .appAlert(alert: $viewModel.error) { }
        }
    }
}

#Preview {
    OrderView()
        .environment(AccessHandler())
    
}
