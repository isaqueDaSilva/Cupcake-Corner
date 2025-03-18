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
        let basePrice: Double
        var quantity = 1
        var extraFrosting = false
        var addSprinkles = false
        var paymentMethod: PaymentMethod = .cash
        
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
        
        var isLoading = false
        var isSuccessed = false
        var error: ExecutionError?
        var isShowingAboutCupcake = false
        
        func makeOrder(
            with session: URLSession = .shared,
            cupcakeID: UUID?
        ) {
            self.isLoading = true
            
            Task {
                do {
                    guard let cupcakeID else {
                        throw ExecutionError.missingData
                    }
                    
                    let newOrder = setOrder(cupcakeID: cupcakeID)
                    let newOrderData = try encode(newOrder)
                    let (_, response) = try await makeRequest(with: session, newOrderData: newOrderData)
                    
                    try checkResponse(response)
                    
                    isSuccessed = true
                    
                    await MainActor.run {
                        isSuccessed = true
                    }
                } catch let error as ExecutionError{
                    await setError(error)
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
        
        private func encode(_ order: Order.Create) throws(ExecutionError) -> Data {
            do {
                return try JSONEncoder().encode(order)
            } catch {
                throw .encodeFailure
            }
        }
        
        private func makeRequest(
            with session: URLSession,
            newOrderData: Data
        ) async throws(ExecutionError) -> (Data, URLResponse) {
            let token = try TokenGetter.getValue()
            
            let endpoint = Endpoint(
                scheme: EndpointBuilder.httpSchema,
                host: EndpointBuilder.domainName,
                path: EndpointBuilder.makePath(endpoint: .order, path: .create),
                httpMethod: .post,
                headers: [
                    EndpointBuilder.Header.authorization.rawValue : token,
                    EndpointBuilder.Header.contentType.rawValue : EndpointBuilder.HeaderValue.json.rawValue
                ],
                body: newOrderData
            )
            
            let handler = NetworkHandler<ExecutionError>(
                endpoint: endpoint,
                session: session,
                unkwnonURLRequestError: .internalError,
                failureToGetDataError: .decodedFailure
            )
            
            return try await handler.getResponse()
        }
        
        private func checkResponse(_ response: URLResponse) throws(ExecutionError) {
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            
            guard let statusCode, statusCode == 200 else {
                throw .resposeFailed
            }
        }
        
        private func setError(_ error: ExecutionError) async {
            await MainActor.run {
                self.error = error
            }
        }
        
        init(with price: Double) {
            self.basePrice = price
        }
    }
}
