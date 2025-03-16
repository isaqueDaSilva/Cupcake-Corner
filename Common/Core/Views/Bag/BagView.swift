//
//  BagView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/11/25.
//

import ErrorWrapper
import SwiftUI

struct BagView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(UserRepository.self) private var userRepository
    @State private var viewModel: ViewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                OrderFilterPickerView(
                    filter: $viewModel.statusType,
                    filerList: Status.allCases
                )
                .labelsHidden()
                .disabled(viewModel.isLoading)
                
                ScrollView {
                    switch viewModel.isLoading {
                    case true:
                        ProgressView()
                            .containerRelativeFrame(.vertical)
                    case false:
                        switch viewModel.orders.isEmpty {
                        case true:
                            OrderEmptyView()
                                .containerRelativeFrame(.vertical)
                        case false:
                            orderListPopulated
                        }
                    }
                }
            }
            #if CLIENT
            .navigationTitle("Bag")
            #elseif ADMIN
            .navigationTitle("Client Orders")
            #endif
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
                
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.connectionStatus == .disconnected {
                        Button {
                            viewModel.reconnect()
                        } label: {
                            Icon.arrowClockwise.systemImage
                        }
                    }
                }
            }
            .onChange(of: scenePhase) { _, newValue in
                if newValue == .background {
                    Task { await viewModel.disconnect() }
                }
            }
            .onChange(of: userRepository.user) { _, _ in
                if userRepository.user == nil {
                    Task { await viewModel.disconnect() }
                }
            }
            .errorAlert(error: $viewModel.error) { }
        }
    }
    
    init(isPreview: Bool = false) {
        self._viewModel = .init(initialValue: .init(isPreview: isPreview))
    }
}

extension BagView {
    @ViewBuilder
    private var orderListPopulated: some View {
        LazyVStack(spacing: 10) {
            orderList
        }
    }
}

extension BagView {
    @ViewBuilder
    private var orderList: some View {
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
    BagView(isPreview: true)
        .environment(UserRepository())
}
