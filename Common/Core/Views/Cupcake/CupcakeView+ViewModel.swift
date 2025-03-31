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
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    try await withThrowingTaskGroup(of: Void.self) { [weak self] group in
                        guard let self else { return }
                        
                        group.addTask { [weak self] in
                            guard let self else { return }
                            try await self.fetchCupcakes(session: session)
                        }
                        
                        #if CLIENT
                        group.addTask { [weak self] in
                            guard let self else { return }
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
            let path = EndpointBuilder.Path.get(false)
            #elseif ADMIN
            let path = EndpointBuilder.Path.get(true)
            #endif
            
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

#if CLIENT
extension CupcakeView.ViewModel {
    private func fetchNewestCupcake(session: URLSession) async throws(ExecutionError) {
        let (data, response) = try await getData(for: .newest, session: session)
        try Network.checkResponse(response)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let newestCupcake = try Network.decodeResponse(type: Cupcake.self, by: data, with: decoder)
        
        await MainActor.run { [weak self] in
            guard let self else { return }
            
            self.newestCupcake = newestCupcake
        }
    }
}
#endif

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
