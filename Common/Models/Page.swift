//
//  PageMetadata.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 6/25/25.
//

import Foundation

struct Page<T>: Decodable where T: Decodable {
    let items: [T]
    let metadata: PageMetadata
}

struct PageMetadata: Decodable {
    let page: Int
    let per: Int
    let total: Int
    
    init() {
        self.page = 1
        self.per = 0
        self.total = 0
    }
}
