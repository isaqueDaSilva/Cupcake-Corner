//
//  AppType.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//

let appType: String = {
    #if CLIENT
    "client"
    #elseif ADMIN
    "admin"
    #endif
}()
