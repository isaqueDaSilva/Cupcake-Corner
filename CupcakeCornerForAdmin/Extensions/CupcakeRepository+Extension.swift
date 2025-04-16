//
//  CupcakeRepository+Extension.swift
//  CupcakeCornerForAdmin
//
//  Created by Isaque da Silva on 4/16/25.
//

import Foundation

extension CupcakeRepository {
    func updateStorage(with action: Action) {
        switch action {
        case .create(let cupcake), .update(let cupcake):
            guard let cupcakeID = cupcake.id else {
                self.error = .missingData
                return
            }
            
            cupcakesDictionary[cupcakeID] = cupcake
        case .delete(let cupcakeID):
            cupcakesDictionary.removeValue(forKey: cupcakeID)
        }
    }
}
