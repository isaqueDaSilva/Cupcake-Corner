//
//  Network.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/25/25.
//

import Foundation
import HTTPTypes
import HTTPTypesFoundation

typealias Response = HTTPResponse
typealias DataAndResponse = (Data, Response)

struct Network {
    private let authority = "localhost:8080"
    private let method: HTTPRequest.Method
    private let scheme: Scheme
    private let path: String
    private let fields: [HTTPField.Name: String]
    private let requestType: RequestType?
    
    func getResponse(with urlSession: URLSession) async throws -> DataAndResponse {
        var request = HTTPRequest(
            method: self.method,
            scheme: self.scheme.rawValue,
            authority: self.authority,
            path: self.path
        )
        
        for (field, value) in self.fields {
            request.headerFields.append(.init(name: field, value: value))
        }
        
        guard let requestType else { throw AppAlert(title: "Failed to complete the request", description: "Request type is not available.") }
        
        return try await requestType.performTask(with: request, and: urlSession)
    }
    
    func getWebSocketTask(with session: URLSession) -> URLSessionWebSocketTask? {
        var request = HTTPRequest(
            method: self.method,
            scheme: self.scheme.rawValue,
            authority: self.authority,
            path: self.path
        )
        
        for (field, value) in self.fields {
            request.headerFields.append(.init(name: field, value: value))
        }
        
        guard let urlRequest = URLRequest(httpRequest: request) else { return nil }
        
        return session.webSocketTask(with: urlRequest)
    }
    
    init(
        method: HTTPRequest.Method,
        scheme: Scheme,
        path: String,
        fields: [HTTPField.Name : String],
        requestType: RequestType? = nil
    ) {
        self.method = method
        self.scheme = scheme
        self.path = "/api/\(path)"
        self.fields = fields
        self.requestType = requestType
    }
}

extension Network {
    enum RequestType {
        case upload(Data)
        case get
        
        func performTask(with request: HTTPRequest, and urlSession: URLSession) async throws -> DataAndResponse {
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
}
