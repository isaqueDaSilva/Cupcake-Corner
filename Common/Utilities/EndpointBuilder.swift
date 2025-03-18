//
//  EndpointBuilder.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import Foundation

enum EndpointBuilder {
    static let webSocketSchema = "ws"
    static let httpSchema = "http"
    static let port = 8080
    static let domainName: String = "127.0.0.1/\(Self.port)"
    
    enum Endpoint: String {
        case cupcake = "cupcake"
        case order = "order"
        case api = ""
        case user = "user"
        case balance = "balance"
    }
    
    enum Path {
        case all(Bool?)
        case get
        case create
        case update
        case delete(UUID?)
        case channel
        case login
        case signOut
        case newest
        
        var rawValue: String {
            switch self {
            case .all(let boolValue):
                let path = "all"
                
                if let boolValue {
                    return path + "/\(boolValue.description)"
                } else {
                    return path
                }
            case .get:
                return "get"
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
                return "login/\(appType)"
            case .signOut:
                return "logout"
            case .newest:
                return "newest"
            }
        }
    }
    
    enum Header: String {
        case bearer = "Bearer"
        case basic = "Basic"
        case authorization = "Authorization"
        case contentType = "Content-Type"
    }
    
    enum HeaderValue: String {
        case json = "application/json"
    }
    
    static func makePath(endpoint: Endpoint, path: Path?) -> String {
        let endpoint = "/\(endpoint.rawValue)"
        
        if let path {
            return endpoint + "/\(path.rawValue)"
        } else {
            return endpoint
        }
    }
}
