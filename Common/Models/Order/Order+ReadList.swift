//
//  Order+ReadList.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/25/25.
//

import Foundation

extension Order {
    struct ReadList: Decodable {
        let list: [Status: [UUID: Order]]
    }
}
