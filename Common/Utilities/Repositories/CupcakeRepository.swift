//
//  CupcakeRepository.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 4/16/25.
//

import Foundation
import Observation

@Observable
@MainActor
final class CupcakeRepository {
    var cupcakesDictionary: [UUID: Cupcake] = [:]
    
    var cupcakes: [Cupcake] {
        cupcakesDictionary.values.sorted(by: { ($0.createdAt ?? .now) > ($1.createdAt ?? .now) })
    }
    
    var isCupcakeListEmpty: Bool {
        cupcakes.isEmpty
    }
    
    func fillStorage(with list: [UUID: Cupcake]) {
        self.cupcakesDictionary = list
    }
    
    init(isPreview: Bool = false) {
        #if DEBUG
        if isPreview {
            self.setPreview()
        }
        #endif
    }
}

#if DEBUG
extension CupcakeRepository {
    func setPreview() {
        self.cupcakesDictionary = Cupcake.mocks
    }
}
#endif
