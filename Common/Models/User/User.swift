//
//  User.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import Foundation
import SwiftData

@Model
final class User {
    #Unique<User>([\.id, \.name, \.email])
    #Index<User>([\.id])
    
    static let fetchDescriptor = FetchDescriptor<User>()
    
    var id: UUID
    var name: String
    var email: String
    var currentAccessTokenExpirationTime: Date
    var currentRefreshTokenExpirationTime: Date
    
    var profile: UserProfile { .init(by: self) }
    
    init(
        with result: CreateUser,
        currentAccessTokenExpirationTime: Date,
        currentRefreshTokenExpirationTime: Date
    ) {
        self.id = result.id
        self.name = result.name
        self.email = result.email
        self.currentAccessTokenExpirationTime = currentAccessTokenExpirationTime
        self.currentRefreshTokenExpirationTime = currentRefreshTokenExpirationTime
    }
}

#if DEBUG
// MARK: - Sample -
extension User {
    static let mock = User(
        with: .init(
            name: "Tim Cook",
            email: "sample@email.com",
            password: .init(),
            keyCollection: .init()
        ),
        currentAccessTokenExpirationTime: .now.addingTimeInterval(350),
        currentRefreshTokenExpirationTime: .now.addingTimeInterval(700)
    )
}
#endif
