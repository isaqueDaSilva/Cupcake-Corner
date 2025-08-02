//
//  RevocationType.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 7/31/25.
//

enum RevocationType: String {
    case signOut
    #if CLIENT
    case deleteAccount
    #endif
    
    var rawValue: String {
        switch self {
        case .signOut:
            "sign out"
        #if CLIENT
        case .deleteAccount:
            "delete account"
        #endif
        }
    }
}
