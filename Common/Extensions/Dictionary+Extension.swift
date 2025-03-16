//
//  Dictionary+Extension.swift
//  CupcakeCornerForAdmin
//
//  Created by Isaque da Silva on 3/10/25.
//

import Foundation

extension Dictionary {
    var toArray: [Value] { Array(values) }
    var toKeyArray: [Key] { Array(keys) }
}
