//
//  Order.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/10/25.
//

import Foundation

struct Order: Identifiable {
    let id: UUID
    let userName: String
    let paymentMethod: PaymentMethod
    let cupcakeName: String
    let quantity: Int
    let extraFrosting: Bool
    let addSprinkles: Bool
    let finalPrice: Double
    let status: Status
    let orderTime: Date
    let readyForDeliveryTime: Date?
    let deliveredTime: Date?
}

extension Order: Codable {
    enum CodingKeys: CodingKey {
        case id
        case userName
        case paymentMethod
        case cupcakeName
        case quantity
        case extraFrosting
        case addSprinkles
        case finalPrice
        case status
        case orderTime
        case readyForDeliveryTime
        case deliveredTime
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.userName = try container.decode(String.self, forKey: .userName)
        self.paymentMethod = try container.decode(PaymentMethod.self, forKey: .paymentMethod)
        self.cupcakeName = try container.decode(String.self, forKey: .cupcakeName)
        self.quantity = try container.decode(Int.self, forKey: .quantity)
        self.extraFrosting = try container.decode(Bool.self, forKey: .extraFrosting)
        self.addSprinkles = try container.decode(Bool.self, forKey: .addSprinkles)
        self.finalPrice = try container.decode(Double.self, forKey: .finalPrice)
        self.status = try container.decode(Status.self, forKey: .status)
        self.orderTime = try container.decode(Date.self, forKey: .orderTime)
        self.readyForDeliveryTime = try container.decodeIfPresent(Date.self, forKey: .readyForDeliveryTime)
        self.deliveredTime = try container.decodeIfPresent(Date.self, forKey: .deliveredTime)
    }
}

extension Order {
    var title: String {
        #if CLIENT
        cupcakeName
        #elseif ADMIN
        userName
        #endif
    }
    
    var description: String {
        #if CLIENT
        let text = """
        Quantity: \(quantity)
        Add Sprinkles: \(addSprinkles ? "Yes" : "No")
        Extra Frosting: \(extraFrosting ? "Yes" : "No")
        Status: \(status.displayedName)
        Order Time: \(orderTime.dateString())
        Out For Delivery: \(readyForDeliveryTime?.dateString() ?? "N/A"),
        Delivered: \(deliveredTime?.dateString() ?? "N/A")
        Payment Method: \(paymentMethod.displayedName)
        """
        return text

        #elseif ADMIN
        let text = """
        Payment Method: \(paymentMethod.displayedName)
        Cupcake: \(cupcakeName)
        Quantity: \(quantity)
        Add Sprinkles: \(addSprinkles ? "Yes" : "No")
        Extra Frosting: \(extraFrosting ? "Yes" : "No")
        Status: \(status.displayedName)
        Order Time: \(orderTime.dateString())
        Out For Delivery: \(readyForDeliveryTime?.dateString() ?? "N/A")
        Delivered: \(deliveredTime?.dateString() ?? "N/A")
        """

        return text
        #endif
    }
}

#if DEBUG
extension Order {
    init(cupcakeFlavor: String = "Flavor: \(Int.random(in: 1...100))") {
        let status = Status.allStatusCase.randomElement() ?? .delivered
        let orderTime = Date.randomDate()
        
        self.id = .init()
        self.userName = "User \(Int.random(in: 1...100))"
        self.paymentMethod = .allCases.randomElement() ?? .cash
        self.cupcakeName = cupcakeFlavor
        self.quantity = Int.random(in: 1...20)
        self.extraFrosting = Bool.random()
        self.addSprinkles = Bool.random()
        self.finalPrice = Double.random(in: 20...100)
        self.status = status
        self.orderTime = orderTime
        self.readyForDeliveryTime = status == .readyForDelivery || status == .delivered ? orderTime.addingTimeInterval(600) : nil
        self.deliveredTime = status == .delivered ? orderTime.addingTimeInterval(1200) : nil
    }
    
    static let mocksDict: [Status: [UUID: Order]] = {
        let mocks: [Order] = [
            .init(),
            .init(),
            .init(),
            .init(),
            .init(),
            .init(),
            .init(),
            .init(),
            .init(),
            .init()
        ]
        
        var mocksDict = [Status: [UUID: Order]]()
        
        mocks.forEach { mock in
            if mocksDict[mock.status] == nil {
                mocksDict[mock.status] = [mock.id: mock]
            } else {
                mocksDict[mock.status]?.updateValue(
                    mock,
                    forKey: mock.id
                )
            }
        }
        
        return mocksDict
    }()
}
#endif
