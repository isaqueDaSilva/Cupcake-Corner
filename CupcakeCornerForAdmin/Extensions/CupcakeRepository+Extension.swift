//
//  CupcakeRepository+Extension.swift
//  CupcakeCornerForAdmin
//
//  Created by Isaque da Silva on 4/16/25.
//

import ErrorWrapper
import Foundation

extension CupcakeRepository {
    func updateStorage(with action: Action) throws(ExecutionError) {
        switch action {
        case .create(let cupcake), .update(let cupcake):
            guard let cupcakeID = cupcake.id else {
                throw .missingData
            }
            
            cupcakesDictionary[cupcakeID] = cupcake
        case .delete(let cupcakeID):
            cupcakesDictionary.removeValue(forKey: cupcakeID)
        }
    }
}
