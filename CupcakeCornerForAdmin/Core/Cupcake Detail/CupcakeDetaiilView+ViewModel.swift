//
//  CupcakeDetaiilView+ViewModel.swift
//  CupcakeCornerForAdmin
//
//  Created by Isaque da Silva on 3/11/25.
//

import ErrorWrapper
import Foundation
import NetworkHandler
import Observation

extension CupcakeDetailView {
    @Observable
    @MainActor
    final class ViewModel {
        var isLoading = false
        var isShowingDeleteAlert = false
        var error: ExecutionError?
        var isShowingUpdateCupcakeView = false
        
        func deleteCupcake(
            with cupcakeID: UUID?,
            _ session: URLSession = .shared,
            completation: @escaping (UUID) -> Void
        ) {
            self.isLoading = true
            
            Task {
                do {
                    guard let cupcakeID else { throw ExecutionError.missingData }
                    
                    let (_, response) = try await makeRequest(with: cupcakeID, and: session)
                    
                    try checkResponse(response)
                    
                    await MainActor.run {
                        completation(cupcakeID)
                    }
                } catch let error as ExecutionError {
                    await setError(error)
                }
                
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
        
        func makeRequest(with cupcakeID: UUID, and session: URLSession) async throws(ExecutionError) -> (Data, URLResponse) {
            let endpoint = Endpoint(
                scheme: EndpointBuilder.httpSchema,
                host: EndpointBuilder.domainName,
                path: EndpointBuilder.makePath(endpoint: .cupcake, path: .delete(cupcakeID)),
                httpMethod: .delete
            )
            
            let handler = NetworkHandler<ExecutionError>(
                endpoint: endpoint,
                session: session,
                unkwnonURLRequestError: .internalError,
                failureToGetDataError: .failedToGetData
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
    }
}

