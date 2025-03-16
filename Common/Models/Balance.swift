//
//  Balance.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/14/25.
//

import Foundation

struct Balance: Codable {
    let totalSpent: Double
    let totalOfPurchase: Int
    let purchasingQuantityAverage: Int
    let mostPurchaseFlavor: String
    let purchaseValuePerFlavor: [String: Int]
    let fullHistory: [String: [Order]]
}

extension Balance {
    static let mock: Balance = {
        let flavors = [
            "Flavor: \(Int.random(in: 1...100))",
            "Flavor: \(Int.random(in: 1...100))",
            "Flavor: \(Int.random(in: 1...100))"
        ]
        
        let orders: [Order] = [
            .init(cupcakeFlavor: flavors[Int.random(in: 0...2)]),
            .init(cupcakeFlavor: flavors[Int.random(in: 0...2)]),
            .init(cupcakeFlavor: flavors[Int.random(in: 0...2)]),
            .init(cupcakeFlavor: flavors[Int.random(in: 0...2)]),
            .init(cupcakeFlavor: flavors[Int.random(in: 0...2)]),
            .init(cupcakeFlavor: flavors[Int.random(in: 0...2)]),
            .init(cupcakeFlavor: flavors[Int.random(in: 0...2)]),
            .init(cupcakeFlavor: flavors[Int.random(in: 0...2)]),
            .init(cupcakeFlavor: flavors[Int.random(in: 0...2)]),
            .init(cupcakeFlavor: flavors[Int.random(in: 0...2)]),
            .init(cupcakeFlavor: flavors[Int.random(in: 0...2)]),
            .init(cupcakeFlavor: flavors[Int.random(in: 0...2)]),
        ]
        
        let totalSpent = orders.reduce(0, { $0 + $1.finalPrice })
        let totalOfPurchase = orders.reduce(0, { $0 + $1.quantity })
        
        var historyByFlavors = [String: [Order]]()
        var purchaseValuePerFlavor = [String: Int]()
        
        for order in orders {
            if historyByFlavors[order.cupcakeName] == nil {
                historyByFlavors[order.cupcakeName] = [order]
                purchaseValuePerFlavor[order.cupcakeName] = order.quantity
            } else {
                historyByFlavors[order.cupcakeName]?.append(order)
                purchaseValuePerFlavor[order.cupcakeName]? += order.quantity
            }
        }
        
        let mostPurchaseFlavor = historyByFlavors.sorted(by: { $0.value.count > $1.value.count })[0].key
        
        let balance = Balance(
            totalSpent: totalSpent,
            totalOfPurchase: totalOfPurchase,
            purchasingQuantityAverage: totalOfPurchase / flavors.count,
            mostPurchaseFlavor: mostPurchaseFlavor,
            purchaseValuePerFlavor: purchaseValuePerFlavor,
            fullHistory: historyByFlavors
        )
        
        return balance
    }()
}
