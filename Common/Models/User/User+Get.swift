//
//  User+Get.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import Foundation

extension User {
    struct Get: Codable, Sendable, Equatable {
        let id: UUID
        let name: String
        let email: String
    }
}
