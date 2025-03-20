//
//  LoginResponse.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//

struct LoginResponse: Codable, Equatable {
    let jwtToken: Token
    let userProfile: User.Get
}
