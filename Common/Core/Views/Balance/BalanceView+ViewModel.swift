//
//  BalanceView+ViewModel.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/14/25.
//

import ErrorWrapper
import Foundation
import NetworkHandler
import Observation

extension BalanceView {
    @Observable
    @MainActor
    final class ViewModel {
        var balance: Balance?
        var initialDate = Date().addingTimeInterval(-.oneDay)
        var finalDate = Date()
        
        var isShowingSetFilter = false
        var isLoading = false
        var error: ExecutionError?
        
        var flavors: [String] {
            balance?.fullHistory.toKeyArray ?? []
        }
        
        func getBalance(session: URLSession = .shared) {
            self.isLoading = true
            
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    let requestData = try makeRequestData()
                    let (data, response) = try await getData(with: requestData,session: session)
                 
                    try Network.checkResponse(response)
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    let balance = try Network.decodeResponse(type: Balance.self, by: data, with: decoder)
                    
                    await MainActor.run { [weak self] in
                        guard let self else { return }
                        
                        self.balance = balance
                        self.isLoading = false
                        self.isShowingSetFilter = false
                    }
                } catch let error as ExecutionError {
                    await setError(error)
                }
            }
        }
        
        private func makeRequestData() throws(ExecutionError) -> Data {
            let balanceRequest = Balance.Get(from: initialDate, to: finalDate)
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            
            return try Network.encodeData(balanceRequest, encoder: encoder)
        }
        
        private func getData(with requestBody: Data, session: URLSession) async throws(ExecutionError) -> (Data, URLResponse) {
            let token = try TokenGetter.getValue()
            
            return try await Network.getData(
                path: EndpointBuilder.makePath(endpoint: .balance, path: .get),
                httpMethod: .post,
                headers: [
                    EndpointBuilder.Header.contentType.rawValue: EndpointBuilder.HeaderValue.json.rawValue,
                    EndpointBuilder.Header.authorization.rawValue : token
                ],
                body: requestBody,
                session: session
            )
        }
        
        private func setError(_ error: ExecutionError) async {
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                self.error = error
                self.isLoading = false
            }
        }
        
        init(isPreview: Bool = false) {
            if isPreview {
                self.balance = .mock
            }
        }
    }
}
