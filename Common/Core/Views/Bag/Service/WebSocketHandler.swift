//
//  WebSocketHandler.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/12/25.
//

import ErrorWrapper
import Foundation
import NetworkHandler
import WebSocketHandler

enum WebSocketHandler {
    static func connectInChannel(with token: String, session: URLSession) async -> WebSocketClient {
        let endpoint = makeChannelEndpoint(with: token)
        let wsClientService = WebSocketClient(session: session, configuration: .init(endpoint: endpoint))
        return wsClientService
    }
    
    static private func makeChannelEndpoint(with token: String) -> Endpoint {
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
        
        return endpoint
    }
}
