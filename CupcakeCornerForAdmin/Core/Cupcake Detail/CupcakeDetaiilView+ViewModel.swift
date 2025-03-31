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
            
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    guard let cupcakeID else { throw ExecutionError.missingData }
                    
                    let (_, response) = try await self.makeRequest(with: cupcakeID, and: session)
                    
                    try Network.checkResponse(response)
                    
                    await MainActor.run { [weak self] in
                        guard self != nil else { return }
                        
                        completation(cupcakeID)
                    }
                } catch let error as ExecutionError {
                    await setError(error)
                }
                
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    
                    self.isLoading = false
                }
            }
        }
        
        func makeRequest(with cupcakeID: UUID, and session: URLSession) async throws(ExecutionError) -> (Data, URLResponse) {
            let token = try TokenGetter.getValue()
            
            return try await Network.getData(
                path: EndpointBuilder.makePath(endpoint: .cupcake, path: .delete(cupcakeID)),
                httpMethod: .delete,
                headers: [EndpointBuilder.Header.authorization.rawValue : token],
                session: session
            )
        }
        
        private func setError(_ error: ExecutionError) async {
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                self.error = error
            }
        }
    }
}

