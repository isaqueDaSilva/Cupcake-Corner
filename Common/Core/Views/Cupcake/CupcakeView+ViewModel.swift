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
            cupcakesDictionary.toArray
        }
        
        var isCupcakeListEmpty: Bool {
            #if CLIENT
            cupcakes.isEmpty && newestCupcake == nil
            #else
            cupcakes.isEmpty
            #endif
        }
        
        var isLoading = false
        var error: ExecutionError?
        
        #if ADMIN
        var isShowingCreateNewCupcake = false
        #endif
        
        #if CLIENT
        var newestCupcake: Cupcake?
        #endif
        
        func fetchCupcakes(session: URLSession = .shared) {
            self.isLoading = true
            Task {
                do {
                    let (data, response) = try await getData(session: session)
                    
                    try checkResponse(response)
                    
                    var cupcakes = try decodeCupcakes(by: data)
                    let newestCupcake = cupcakes.removeFirst()
                    
                    var cupcakesDictionary = [UUID: Cupcake]()
                    
                    for cupcake in cupcakes {
                        if let cupcakeID = cupcake.id {
                            cupcakesDictionary.updateValue(cupcake, forKey: cupcakeID)
                        }
                    }
                    
                    if cupcakes.count - 1 != cupcakesDictionary.count {
                        await self.setError(
                            .init(
                                title: "Failed to load all cupcakes",
                                descrition: ""
                            )
                        )
                    }
                    
                    await MainActor.run {
                        self.cupcakesDictionary = cupcakesDictionary
                        
                        #if CLIENT
                        self.newestCupcake = newestCupcake
                        #endif
                    }
                } catch let error as ExecutionError {
                    await self.setError(error)
                }
                
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
        
        private func getData(session: URLSession) async throws(ExecutionError) -> (Data, URLResponse) {
            let endpoint = Endpoint(
                scheme: EndpointBuilder.httpSchema,
                host: EndpointBuilder.domainName,
                path: EndpointBuilder.makePath(endpoint: .cupcake, path: .all),
                httpMethod: .get
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
        
        private func decodeCupcakes(by data: Data) throws(ExecutionError) -> [Cupcake] {
            guard let cupcakes = try? JSONDecoder().decode([Cupcake].self, from: data) else {
                throw .decodedFailure
            }
            
            return cupcakes
        }
        
        private func setError(_ error: ExecutionError) async {
            await MainActor.run {
                self.error = error
            }
        }
        
        init(isPreview: Bool = false) {
            if isPreview {
                #if DEBUG
                var cupcakes = Cupcake.mocks
                #endif
                
                #if CLIENT
                if let newestCupcakeKey = cupcakes.first?.key {
                    self.newestCupcake = cupcakes.removeValue(forKey: newestCupcakeKey)
                }
                self.cupcakesDictionary = cupcakes.filter({ $0.value.id != newestCupcake?.id })
                #else
                #if DEBUG
                self.cupcakesDictionary = cupcakes
                #endif
                #endif
                
            } else {
                fetchCupcakes()
            }
        }
    }
}
