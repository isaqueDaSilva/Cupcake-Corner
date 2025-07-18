//
//  OrderRequestView+ViewModel.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/10/25.
//

import ErrorWrapper
import Foundation
import NetworkHandler
import Observation

extension OrderRequestView {
    @Observable
    @MainActor
    final class ViewModel {
        private let basePrice: Double
        var quantity = 1
        
        var isLoading = false
        var isSuccessed = false
        var error: ExecutionError? = nil
        
        var finalPrice: Double {
            basePrice * Double(quantity)
        }
        
        func makeOrder(with cupcakeID: UUID?, session: URLSession = .shared) {
            guard let cupcakeID else {
                self.error = .missingData
                return
            }
            
            self.isLoading = true
            
            Task { [weak self] in
                guard let self else { return }
                
                let token = try TokenGetter.getValue()
                
                let newOrder = Order(
                    cupcakeInformation: cupcakeID,
                    quantity: self.quantity,
                    finalPrice: self.finalPrice
                )
                
                let (_, response) = try await newOrder.create(
                    with: token,
                    session: session
                )
                
                guard response.status == .created else {
                    return await self.setError(.badResponse)
                }
                
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    
                    self.isLoading = false
                    self.isSuccessed = true
                }
            }
        }
        
        private func setError(_ error: ExecutionError) async {
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.isLoading = false
                self.error = error
            }
        }
        
        init(with price: Double) {
            self.basePrice = price
        }
    }
}
