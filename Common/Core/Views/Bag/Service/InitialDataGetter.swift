//
//  InitialDataGetter.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/12/25.
//

import ErrorWrapper
import Foundation
import NetworkHandler

enum InitialDataGetter {
    static func getInitialOrders(
        with token: String,
        session: URLSession
    ) async throws(ExecutionError) -> Data {
        let (data, response) = try await getData(with: token, session: session)
        try checkResponse(response)
        return data
    }
    
    static private func getData(
        with token: String,
        session: URLSession
    ) async throws(ExecutionError) -> (Data, URLResponse)  {
        let endpoint = Endpoint(
            scheme: EndpointBuilder.webSocketSchema,
            host: EndpointBuilder.domainName,
            path: EndpointBuilder.makePath(endpoint: .order, path: .channel),
            httpMethod: .get,
            headers: [
                EndpointBuilder.Header.authorization.rawValue : token,
                "Content-Type" : "application/vnd.api+json"
            ]
        )
        
        let handler = NetworkHandler<ExecutionError>(
            endpoint: endpoint,
            session: session,
            unkwnonURLRequestError: .internalError,
            failureToGetDataError: .failedToGetData
        )
        
        return try await handler.getResponse()
    }
    
    static private func checkResponse(_ response: URLResponse) throws(ExecutionError) {
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        
        guard let statusCode, statusCode == 200 else {
            throw .resposeFailed
        }
    }
}
