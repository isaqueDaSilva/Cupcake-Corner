//
//  OrderRequestView+ViewModel.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/10/25.
//

import Foundation

extension OrderRequestView {
    @Observable
    @MainActor
    final class ViewModel {
        private let basePrice: Double
        var quantity = 1
        
        var isLoading = false
        var isSuccessed = false
        var alert: AppAlert? = nil
        
        var finalPrice: Double {
            basePrice * Double(quantity)
        }
        
        func makeOrder(with cupcakeID: UUID?, session: URLSession = .shared) {
            guard let cupcakeID else {
                self.alert = .missingData
                return
            }
            
            self.isLoading = true
            
            Task { [weak self] in
                guard let self else { return }
                
                let token = try TokenHandler.getValue(key: .accessToken)
                
                let newOrder = Order(
                    quantity: self.quantity,
                    finalPrice: self.finalPrice
                )
                
                let (_, response) = try await newOrder.create(
                    with: token,
                    cupcakeID: cupcakeID,
                    session: session
                )
                
                guard response.status == .created else {
                    return await self.setAlert(.badResponse, isSuccessed: false)
                }
                
                await self.setAlert(
                    .init(
                        title: "Order Sent with Success",
                        description: "Go to the bag and track the progress of your order in real time."
                    ),
                    isSuccessed: true
                )
            }
        }
        
        private func setAlert(_ alert: AppAlert, isSuccessed: Bool) async {
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.isLoading = false
                self.isSuccessed = isSuccessed
                self.alert = alert
            }
        }
        
        init(with price: Double) {
            self.basePrice = price
        }
    }
}
