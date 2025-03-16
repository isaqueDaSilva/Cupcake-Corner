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
            
            Task {
                do {
                    let requestData = try makeRequestData()
                    let (data, response) = try await getData(with: requestData,session: session)
                 
                    try checkResponse(response)
                    
                    let balance = try await decodeBalance(by: data)
                    
                    await MainActor.run {
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
            let request = Balance.Get(from: initialDate, to: finalDate)
            
            do {
                return try JSONEncoder().encode(request)
            } catch {
                throw .encodeFailure
            }
        }
        
        private func getData(with requestBody: Data, session: URLSession) async throws(ExecutionError) -> (Data, URLResponse) {
            let endpoint = Endpoint(
                scheme: EndpointBuilder.httpSchema,
                host: EndpointBuilder.domainName,
                path: EndpointBuilder.makePath(endpoint: .balance, path: nil),
                httpMethod: .get,
                body: requestBody
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
        
        private func decodeBalance(by data: Data) async throws(ExecutionError) -> Balance {
            guard let balance = try? JSONDecoder().decode(Balance.self, from: data) else {
                throw .decodedFailure
            }
            
            return balance
        }
        
        private func setError(_ error: ExecutionError) async {
            await MainActor.run {
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
