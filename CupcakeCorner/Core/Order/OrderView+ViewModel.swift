//
//  OrderView+ViewModel.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/10/25.
//

import ErrorWrapper
import Foundation
import NetworkHandler
import Observation

extension OrderView {
    @Observable
    @MainActor
    final class ViewModel {
        private let basePrice: Double
        var quantity = 1
        var extraFrosting = false
        var addSprinkles = false
        var paymentMethod: PaymentMethod = .cash
        
        var isLoading = false
        var isSuccessed = false
        var error: ExecutionError? = nil
        var isShowingAboutCupcake = false
        
        var extraFrostingPrice: Double {
            Double(quantity) * 1.5
        }
        
        var addSprinklesPrice: Double {
            Double(quantity) / 2.0
        }
        
        var finalPrice: Double {
            var cupcakeCost: Double {
                basePrice * Double(quantity)
            }
            
            var extraFrostingTax: Double {
                extraFrosting ? extraFrostingPrice : 0
            }
            
            var addSprinklesTax: Double {
                addSprinkles ? addSprinklesPrice : 0
            }
            
            let finalPrice = cupcakeCost + extraFrostingTax + addSprinklesTax
        
            return finalPrice
        }
        
        func makeOrder(
            with session: URLSession = .shared,
            cupcakeID: UUID?
        ) {
            self.isLoading = true
            
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    guard let cupcakeID else {
                        throw ExecutionError.missingData
                    }
                    
                    let newOrder = self.setOrder(cupcakeID: cupcakeID)
                    let newOrderData = try Network.encodeData(newOrder)
                    let (_, response) = try await self.makeRequest(with: session, newOrderData: newOrderData)
                    
                    try Network.checkResponse(response)
                    
                    await MainActor.run { [weak self] in
                        guard let self else { return }
                        
                        self.isSuccessed = true
                    }
                } catch let error as ExecutionError{
                    await self.setError(error)
                }
                
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
        
        private func setOrder(cupcakeID: UUID) -> Order.Create {
            .init(
                cupcakeID: cupcakeID,
                quantity: self.quantity,
                extraFrosting: self.extraFrosting,
                addSprinkles: self.extraFrosting,
                finalPrice: self.finalPrice,
                paymentMethod: paymentMethod
            )
        }
        
        private func makeRequest(
            with session: URLSession,
            newOrderData: Data
        ) async throws(ExecutionError) -> (Data, URLResponse) {
            let token = try TokenGetter.getValue()
            
            return try await Network.getData(
                path: EndpointBuilder.makePath(endpoint: .order, path: .create),
                httpMethod: .post,
                headers: [
                    EndpointBuilder.Header.authorization.rawValue : token,
                    EndpointBuilder.Header.contentType.rawValue : EndpointBuilder.HeaderValue.json.rawValue
                ],
                body: newOrderData,
                session: session
            )
        }
        
        private func setError(_ error: ExecutionError) async {
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                self.error = error
            }
        }
        
        init(with price: Double) {
            self.basePrice = price
        }
    }
}
