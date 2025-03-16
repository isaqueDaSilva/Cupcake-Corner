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
    #Unique<User>([\.id, \.name])
    #Index<User>([\.id])
    
    var id: UUID
    var name: String
    var email: String
    
    init(
        with result: Get
    ) {
        self.id = result.id
        self.name = result.name
        self.email = result.email
    }
}

#if DEBUG
// MARK: - Sample -
extension User {
    static let mock = User(
        with: .init(
            id: .init(),
            name: "Tim Cook",
            email: "timcook@apple.com"
        )
    )
}
#endif
