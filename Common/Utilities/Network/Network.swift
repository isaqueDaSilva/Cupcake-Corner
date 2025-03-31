//
//  Network.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/25/25.
//

import ErrorWrapper
import Foundation
import NetworkHandler

enum Network {
    static func getData(
        schema: String = EndpointBuilder.httpSchema,
        host: String = EndpointBuilder.domainName,
        path: String,
        httpMethod: HTTPMethod,
        headers: [String: String] = [:],
        body: Data? = nil,
        session: URLSession
    ) async throws(ExecutionError) -> (Data, URLResponse)  {
        let endpoint = Endpoint(
            scheme: schema,
            host: host,
            path: path,
            httpMethod: httpMethod,
            headers: headers,
            body: body
        )
        
        let handler = NetworkHandler<ExecutionError>(
            endpoint: endpoint,
            session: session,
            unkwnonURLRequestError: .internalError,
            failureToGetDataError: .failedToGetData
        )
        
        return try await handler.getResponse()
    }
    
    static func checkResponse(_ response: URLResponse) throws(ExecutionError) {
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        
        guard let statusCode, statusCode == 200 else {
            throw .resposeFailed
        }
    }
    
    static func encodeData<T: Encodable>(_ model: T, encoder: JSONEncoder = .init()) throws(ExecutionError) -> Data {
        do {
            return try encoder.encode(model)
        } catch {
            throw .encodeFailure
        }
    }
    
    static func decodeResponse<T: Decodable>(
        type: T.Type,
        by data: Data,
        with decoder: JSONDecoder = .init()
    ) throws(ExecutionError) -> T {
        guard let data = try? decoder.decode(T.self, from: data) else {
            throw .decodedFailure
        }
        
        return data
    }
}
