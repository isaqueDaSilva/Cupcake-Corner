//
//  OrderView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/11/25.
//

import ErrorWrapper
import SwiftUI

struct OrderView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Bindable private var userRepository: UserRepository
    @State private var viewModel: ViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                OrderFilterPickerView(
                    filter: $viewModel.statusType
                )
                .labelsHidden()
                .disabled(viewModel.isLoading)
                
                ScrollView {
                    orderListPopulated
                        .overlay {
                            switch viewModel.isLoading {
                            case true:
                                ProgressView()
                            case false:
                                if viewModel.orders.isEmpty {
                                    OrderEmptyView()
                                }
                            }
                        }
                        .opacity(viewModel.isLoading ? 0 : 1)
                }
            }
            .navigationTitle("Order")
            .disabled(viewModel.isLoading)
            .toolbar {
                #if CLIENT
                ToolbarItem(placement: .bottomBar) {
                    InformationLabel(
                        viewModel.totalOfBag,
                        title: "Total of this bag:"
                    )
                }
                #endif
                
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
    
    init(userRepository: UserRepository,isPreview: Bool = false) {
        self._viewModel = .init(initialValue: .init(isPreview: isPreview))
        self._userRepository = .init(userRepository)
    }
}

extension OrderView {
    @ViewBuilder
    private var orderListPopulated: some View {
        LazyVStack(spacing: 10) {
            ForEach(viewModel.orders, id: \.id) { order in
                ItemCard(
                    name: order.title,
                    description: order.description,
                    price: order.finalPrice
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                #if ADMIN
                .contextMenu {
                    changeOrderStatusButton(
                        with: order.id,
                        and: order.status
                    )
                }
                #endif
                .padding(.horizontal)
            }
        }
    }
}

#if ADMIN
extension BagView {
    @ViewBuilder
    private func changeOrderStatusButton(
        with orderID: UUID,
        and currentStatus: Status
    ) -> some View {
        Button {
            viewModel.updateOrder(for: orderID, with: currentStatus)
        } label: {
            switch currentStatus {
            case .ordered:
                Label(
                    "Mark as Ready For Delivery",
                    systemImage: Icon.truck.rawValue
                )
            case .readyForDelivery, .delivered:
                Label(
                    "Mark as Delivered",
                    systemImage: Icon.shippingBox.rawValue
                )
                .disabled(currentStatus == .delivered)
            }
        }
    }
}
#endif

#Preview {
    OrderView(userRepository: UserRepository(), isPreview: true)
}
