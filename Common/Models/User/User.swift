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
    
    init(
        with result: Get
    ) {
        self.id = result.id
        self.name = result.name
    }
}

#if DEBUG
// MARK: - Sample -
extension User {
    static let mock = User(
        with: .init(
            id: .init(),
            name: "Tim Cook"
        )
    )
}
#endif
