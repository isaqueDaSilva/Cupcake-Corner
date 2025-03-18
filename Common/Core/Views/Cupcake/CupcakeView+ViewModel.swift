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
        
        func fetch(session: URLSession = .shared) {
            self.isLoading = true
            Task {
                do {
                    try await withThrowingTaskGroup(of: Void.self) { [weak self] group in
                        guard let self else { return }
                        
                        group.addTask { [weak self] in
                            guard let self else { return }
                            try await self.fetchCupcakes(session: session)
                        }
                        
                        #if CLIENT
                        group.addTask {
                            try await fetchNewestCupcake(session: session)
                        }
                        #endif
                        
                        guard try await group.next() != nil else {
                            group.cancelAll()
                            return
                        }
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
        
        private func fetchCupcakes(session: URLSession) async throws(ExecutionError) {
            #if CLIENT
            let path = EndpointBuilder.Path.all(false)
            #elseif ADMIN
            let path = EndpointBuilder.Path.all(true)
            #endif
            
            let (data, response) = try await getData(for: path, session: session)
            try checkResponse(response)
            
            let cupcakesDictionary = try decode(Cupcake.ListResponse.self, by: data)
            
            await MainActor.run {
                self.cupcakesDictionary = cupcakesDictionary.cupcakes
            }
        }
        
        #if CLIENT
        private func fetchNewestCupcake(session: URLSession) async throws(ExecutionError) {
            let (data, response) = try await getData(for: .newest, session: session)
            try checkResponse(response)
            
            let newestCupcake = try decode(Cupcake.self, by: data)
            
            await MainActor.run {
                self.newestCupcake = newestCupcake
            }
        }
        #endif
        
        private func getData(
            for path: EndpointBuilder.Path,
            session: URLSession
        ) async throws(ExecutionError) -> (Data, URLResponse) {
            let endpoint = Endpoint(
                scheme: EndpointBuilder.httpSchema,
                host: EndpointBuilder.domainName,
                path: EndpointBuilder.makePath(endpoint: .cupcake, path: path),
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
        
        private func decode<T: Decodable>(_ model: T.Type, by data: Data) throws(ExecutionError) -> T {
            guard let model = try? JSONDecoder().decode(T.self, from: data) else {
                throw .decodedFailure
            }
            
            return model
        }
        
        private func setError(_ error: ExecutionError) async {
            await MainActor.run {
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

#if DEBUG
extension CupcakeView.ViewModel {
    func setPreview() {
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
    }
}
#endif
