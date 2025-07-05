//
//  Network.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/25/25.
//

import ErrorWrapper
import Foundation
import HTTPTypes
import HTTPTypesFoundation
import NetworkHandler

typealias Response = HTTPResponse
typealias DataAndResponse = (Data, HTTPResponse)

struct _Network {
    static let authority = "localhost:8080"
    private let method: HTTPRequest.Method
    private let scheme: Scheme
    private let path: String
    private let fields: [HTTPField.Name: String]
    private let requestType: RequestType
    
    func getResponse(with urlSession: URLSession) async throws -> (Data, HTTPResponse) {
        var request = HTTPRequest(
            method: self.method,
            scheme: self.scheme.rawValue,
            authority: Self.authority,
            path: self.path
        )
        
        for (field, value) in self.fields {
            request.headerFields.append(.init(name: field, value: value))
        }
        
        return try await self.requestType.performTask(with: request, and: urlSession)
    }
    
    enum RequestType {
        case upload(Data), get
        
        func performTask(with request: HTTPRequest, and urlSession: URLSession) async throws -> (Data, HTTPResponse) {
            switch self {
            case .upload(let data):
                try await urlSession.upload(for: request, from: data)
            case .get:
                try await urlSession.data(for: request)
            }
        }
    }
    
    enum Scheme: String {
        case https, wss
        
        var rawValue: String {
            switch self {
            case .https:
                "https"
            case .wss:
                "wss"
            }
        }
    }
    
    enum HeaderValue: String {
        case json = "application/json"
        case vdnAPIJSON = "application/vnd.api+json"
    }
    
    init(
        method: HTTPRequest.Method,
        scheme: Scheme,
        path: String,
        fields: [HTTPField.Name : String],
        requestType: RequestType
    ) {
        self.method = method
        self.scheme = scheme
        self.path = path
        self.fields = fields
        self.requestType = requestType
    }
}

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
