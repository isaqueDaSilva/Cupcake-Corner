//
//  EndpointBuilder.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import Foundation

enum EndpointBuilder {
    static let webSocketSchema = "wss"
    static let httpSchema = "https"
    static let domainName: String = "127.0.0.0:8080"
    
    
    static func makePath(endpoint: Endpoint, path: Path?) -> String {
        let endpoint = "/api/\(endpoint.rawValue)"
        
        if let path {
            return endpoint + "/\(path.rawValue)"
        } else {
            return endpoint
        }
    }
}

extension EndpointBuilder {
    enum Endpoint: String {
        case serverPublicKey = "serverPublicKey"
        case cupcake = "cupcake"
        case user = "user"
        case auth = "auth"
        case order = "order"
        case balance = "balance"
    }
}

extension EndpointBuilder {
    enum Path {
        case create
        case get(Bool?)
        case update
        case delete(UUID?)
        case newest
        case login
        case logout
        case channel
        
        var rawValue: String {
            switch self {
            case .get(let isQueringAll):
                let path = "get"
                if let isQueringAll {
                    return path + "/\(isQueringAll.description)"
                } else {
                    return path
                }
            case .create:
                return "create"
            case .update:
                return "update"
            case .delete(let id):
                let path = "delete"
                
                if let id {
                    return path + "/\(id)"
                } else {
                    return path
                }
            case .channel:
                return "channel"
            case .login:
                return "login"
            case .logout:
                return "logout"
            case .newest:
                return "newest"
            }
        }
    }
}

extension EndpointBuilder {
    enum Header: String {
        case bearer = "Bearer"
        case basic = "Basic"
        case authorization = "Authorization"
        case contentType = "Content-Type"
    }
    
    enum HeaderValue: String {
        case json = "application/json"
        case vdnAPIJSON = "application/vnd.api+json"
    }
}
