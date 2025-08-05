//
//  PageMetadata.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 6/25/25.
//

import Foundation

struct Page<T>: Codable where T: Codable {
    let items: [T]
    let metadata: PageMetadata
}

struct PageMetadata: Codable, CustomStringConvertible {
    let page: Int
    let per: Int
    let total: Int
    
    var isLoadedAll: Bool {
        (self.page * self.per) == total
    }
    
    init(page: Int = 0, per: Int = 0, total: Int = 0) {
        self.page = page
        self.per = per
        self.total = total
    }
    
    var description: String {
        "Page: \(self.page); Per: \(self.per); Total: \(self.total)"
    }
}
