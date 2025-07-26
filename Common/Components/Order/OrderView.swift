//
//  OrderView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/11/25.
//

import SwiftUI

struct OrderView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Bindable private var userRepository: UserRepository
    @State private var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                if self.viewModel.isLoading && self.viewModel.orders.isEmpty {
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
                            index: index
                        )
                    } updateAction: { index in
                        #if ADMIN
                        self.viewModel.updateOrder(at: index)
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
            .onChange(of: userRepository.user) { _, _ in
                if userRepository.user == nil {
                    viewModel.disconnect(isWaitingForDisconnect: false)
                }
            }
            .errorAlert(error: $viewModel.error) { }
        }
    }
    
    init(userRepository: UserRepository) {
        self._userRepository = .init(userRepository)
    }
}

#Preview {
    OrderView(userRepository: UserRepository())
}
