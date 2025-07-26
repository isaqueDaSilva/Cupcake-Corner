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
    let cupcakeName: String
    let cupcakeImageName: String?
    let quantity: Int
    let finalPrice: Double
    let status: Status
    let orderTime: Date
    let readyForDeliveryTime: Date?
    let deliveredTime: Date?
    
    init(
        quantity: Int,
        finalPrice: Double
    ) {
        self.id = .init()
        self.userName = ""
        self.cupcakeName = ""
        self.cupcakeImageName = ""
        self.quantity = quantity
        self.finalPrice = finalPrice
        self.status = .ordered
        self.orderTime = .now
        self.readyForDeliveryTime = nil
        self.deliveredTime = nil
    }
}

// MARK: - Encode and Decode strategy -
extension Order: Codable {
    enum CodingKeys: CodingKey {
        case id
        case userName
        case cupcakeImageName
        case cupcakeName
        case quantity
        case finalPrice
        case status
        case orderTime
        case readyForDeliveryTime
        case deliveredTime
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.quantity, forKey: .quantity)
        try container.encode(self.finalPrice, forKey: .finalPrice)
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.userName = try container.decode(String.self, forKey: .userName)
        self.cupcakeName = try container.decode(String.self, forKey: .cupcakeName)
        self.cupcakeImageName = try container.decodeIfPresent(String.self, forKey: .cupcakeImageName)
        self.quantity = try container.decode(Int.self, forKey: .quantity)
        self.finalPrice = try container.decode(Double.self, forKey: .finalPrice)
        self.status = try container.decode(Status.self, forKey: .status)
        self.orderTime = try container.decode(Date.self, forKey: .orderTime)
        self.readyForDeliveryTime = try container.decodeIfPresent(Date.self, forKey: .readyForDeliveryTime)
        self.deliveredTime = try container.decodeIfPresent(Date.self, forKey: .deliveredTime)
    }
}

// MARK: - Network strategy -
extension Order {
    static func requestMorePages(currentPage: Int, with wsClient: WebSocketClient) async throws {
        let message = SendMessage(data: .queryRecords(currentPage + 1))
        
        try await wsClient.send(message)
    }
    
    #if CLIENT
    func create(with token: String, cupcakeID: UUID, session: URLSession) async throws -> DataAndResponse {
        let orderData = try EncoderAndDecoder.encodeData(self)
        
        let request = Network(
            method: .post,
            scheme: .https,
            path: "/order/create/\(cupcakeID.uuidString)",
            fields: [
                .authorization : token,
                .contentType : Network.HeaderValue.json.rawValue
            ],
            requestType: .upload(orderData)
        )
        
        return try await request.getResponse(with: session)
    }
    #endif
    
    #if ADMIN
    func update(with wsClient: WebSocketClient) async throws {
        let updatedStatus: Status = switch self.status {
        case .ordered:
            .readyForDelivery
        case .readyForDelivery:
            .delivered
        case .delivered:
            .delivered
        }
        
        let message = SendMessage(data: .update(self.id, updatedStatus))
        
        try await wsClient.send(message)
    }
    #endif
}

// MARK: - Displaying Customization -
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
        Status: \(status.displayedName)
        Order Time: \(orderTime.dateString())
        Out For Delivery: \(readyForDeliveryTime?.dateString() ?? "N/A"),
        Delivered: \(deliveredTime?.dateString() ?? "N/A")
        """
        return text

        #elseif ADMIN
        let text = """
        Cupcake: \(cupcakeName)
        Quantity: \(quantity)
        Status: \(status.displayedName)
        Order Time: \(orderTime.dateString())
        Out For Delivery: \(readyForDeliveryTime?.dateString() ?? "N/A")
        Delivered: \(deliveredTime?.dateString() ?? "N/A")
        """

        return text
        #endif
    }
}

// MARK: - Mocks -
#if DEBUG
import OrderedCollections

extension Order {
    init(cupcakeFlavor: String = "Flavor: \(Int.random(in: 1...100))") {
        let status = Status.allStatusCase.randomElement() ?? .delivered
        let orderTime = Date.randomDate()
        
        self.id = .init()
        self.userName = "User \(Int.random(in: 1...100))"
        self.cupcakeName = cupcakeFlavor
        self.cupcakeImageName = "dummyimage.jpg"
        self.quantity = Int.random(in: 1...20)
        self.finalPrice = Double.random(in: 20...100)
        self.status = status
        self.orderTime = orderTime
        self.readyForDeliveryTime = status == .readyForDelivery || status == .delivered ? orderTime.addingTimeInterval(600) : nil
        self.deliveredTime = status == .delivered ? orderTime.addingTimeInterval(1200) : nil
    }
    
    static var mocks: [Order] {
        [
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
    }
    
    static let mocksDict: [Status: OrderedDictionary<UUID, Order>] = {
        var mocksDict = [Status: OrderedDictionary<UUID, Order>]()
        
        Self.mocks.forEach { mock in
            if mocksDict[mock.status] == nil {
                mocksDict[mock.status] = [mock.id : mock]
            } else {
                mocksDict[mock.status]?.updateValue(mock, forKey: mock.id)
            }
        }
        
        return mocksDict
    }()
}
#endif
