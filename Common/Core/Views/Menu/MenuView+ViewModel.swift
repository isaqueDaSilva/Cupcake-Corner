//
//  CupcakeView+ViewModel.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import ErrorWrapper
import Foundation
import NetworkHandler
import Observation

extension MenuView {
    @Observable
    @MainActor
    final class ViewModel {
        var isLoading = false
        var error: ExecutionError?
        
        func fetch(session: URLSession = .shared, completation: @escaping (Cupcake.ListResponse) -> Void) {
            self.isLoading = true
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    let cupcakeList = try await self.fetchCupcakes(session: session)
                    
                    await MainActor.run {
                        completation(cupcakeList)
                    }
                } catch let error as ExecutionError {
                    await self.setError(error)
                }
                
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.isLoading = false
                }
            }
        }
        
        private func fetchCupcakes(session: URLSession) async throws(ExecutionError) -> Cupcake.ListResponse {
            let path = EndpointBuilder.Path.get
            
            let (data, response) = try await getData(for: path, session: session)
            try Network.checkResponse(response)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let cupcakeList = try Network.decodeResponse(
                type: Cupcake.ListResponse.self,
                by: data,
                with: decoder
            )
            
            return cupcakeList
        }
        
        private func getData(
            for path: EndpointBuilder.Path,
            session: URLSession
        ) async throws(ExecutionError) -> (Data, URLResponse) {
            try await Network.getData(
                path: EndpointBuilder.makePath(endpoint: .cupcake, path: path),
                httpMethod: .get,
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
