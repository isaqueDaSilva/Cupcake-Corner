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

extension CupcakeView {
    @Observable
    @MainActor
    final class ViewModel {
        var cupcakesDictionary: [UUID: Cupcake] = [:]
        
        var cupcakes: [Cupcake] {
            cupcakesDictionary.toArray.sorted(by: { ($0.createdAt ?? .now) > ($1.createdAt ?? .now) })
        }
        
        var isCupcakeListEmpty: Bool {
            cupcakes.isEmpty
        }
        
        var isLoading = false
        var error: ExecutionError?
        
        #if ADMIN
        var isShowingCreateNewCupcake = false
        #endif
        
        func fetch(session: URLSession = .shared) {
            self.isLoading = true
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    try await self.fetchCupcakes(session: session)
                } catch let error as ExecutionError {
                    await self.setError(error)
                }
                
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    
                    self.isLoading = false
                }
            }
        }
        
        private func fetchCupcakes(session: URLSession) async throws(ExecutionError) {
            let path = EndpointBuilder.Path.get
            
            let (data, response) = try await getData(for: path, session: session)
            try Network.checkResponse(response)
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let cupcakesDictionary = try Network.decodeResponse(
                type: Cupcake.ListResponse.self,
                by: data,
                with: decoder
            )
            
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                self.cupcakesDictionary = cupcakesDictionary.cupcakes
            }
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
        
        init(isPreview: Bool = false) {
            if isPreview {
                #if DEBUG
                self.setPreview()
                #endif
            } else {
                self.fetch()
            }
        }
    }
}

#if ADMIN
extension CupcakeView.ViewModel {
    func updateStorage(with action: Action) {
        switch action {
        case .create(let cupcake), .update(let cupcake):
            guard let cupcakeID = cupcake.id else {
                self.error = .missingData
                return
            }
            
            cupcakesDictionary[cupcakeID] = cupcake
        case .delete(let cupcakeID):
            cupcakesDictionary.removeValue(forKey: cupcakeID)
        }
    }
}
#endif

#if DEBUG
extension CupcakeView.ViewModel {
    func setPreview() {
        #if DEBUG
        self.cupcakesDictionary = Cupcake.mocks
        #endif
    }
}
#endif
