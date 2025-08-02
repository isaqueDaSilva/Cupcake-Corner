//
//  Cupcake.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import Foundation

typealias CreateCupcake = CreateOrReadCupcake
typealias ReadCupcake = CreateOrReadCupcake

struct CreateOrReadCupcake: Identifiable, Hashable, Equatable {
    let id: UUID
    var flavor: String
    var imageName: String?
    var ingredients: [String]
    var price: Double
    let createdAt: Date?
    
    #if ADMIN
    init(flavor: String, ingredients: [String], price: Double) {
        self.id = .init()
        self.flavor = flavor
        self.imageName = nil
        self.ingredients = ingredients
        self.price = price
        self.createdAt = nil
    }
    #endif
}

// MARK: - Encode and Decode strategy -
extension CreateOrReadCupcake: Codable {
    enum Key: String, CodingKey {
        case id
        case flavor
        case imageName
        case ingredients
        case price
        case createdAt
    }
    
    #if ADMIN
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        try container.encode(self.flavor, forKey: .flavor)
        try container.encode(self.ingredients, forKey: .ingredients)
        try container.encode(self.price, forKey: .price)
    }
    #endif
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.flavor = try container.decode(String.self, forKey: .flavor)
        self.imageName = try container.decode(String.self, forKey: .imageName)
        self.ingredients = try container.decode([String].self, forKey: .ingredients)
        self.price = try container.decode(Double.self, forKey: .price)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
}

// MARK: - Network strategy -
extension ReadCupcake {
    static func fetch(with token: String, currentPage: Int, and session: URLSession) async throws -> DataAndResponse {
        let request = Network(
            method: .patch,
            scheme: .https,
            path: "/cupcake/get?page=\(currentPage)",
            fields: [
                .authorization : token,
                .contentType : Network.HeaderValue.json.rawValue
            ],
            requestType: .get
        )
        
        return try await request.getResponse(with: session)
    }
}

#if ADMIN
extension CreateCupcake {
    private func checkIfIsValid() throws(AppAlert) {
        guard !ingredients.isEmpty else {
            throw .emptyIngredientsList
        }
        
        guard price > 0.1 else {
            throw .priceOutTheRange
        }
    }
    
    func createCupcake(
        with token: String,
        and session: URLSession
    ) async throws -> DataAndResponse {
        try self.checkIfIsValid()
        
        let cupcakeData = try EncoderAndDecoder.encodeData(self)
        
        let request = Network(
            method: .post,
            scheme: .https,
            path: "/cupcake/create",
            fields: [
                .authorization : token,
                .contentType : Network.HeaderValue.json.rawValue
            ],
            requestType: .upload(cupcakeData)
        )
        
        return try await request.getResponse(with: session)
    }
}

extension CreateOrReadCupcake {
    func update(
        keysAndValues json: [Key.RawValue: Any],
        token: String,
        and session: URLSession
    ) async throws -> (Data, Response) {
        let updatedCupcakeData = try JSONSerialization.data(withJSONObject: json)
        
        let request = Network(
            method: .patch,
            scheme: .https,
            path: "/cupcake/update/\(self.id.uuidString)",
            fields: [
                .authorization : token,
                .contentType : Network.HeaderValue.json.rawValue
            ],
            requestType: .upload(updatedCupcakeData)
        )
        
        return try await request.getResponse(with: session)
    }
    
    func delete(with token: String, and session: URLSession) async throws -> Response {
        let request = Network(
            method: .patch,
            scheme: .https,
            path: "/cupcake/delete/\(self.id.uuidString)",
            fields: [
                .authorization : token
            ],
            requestType: .get
        )
        
        let (_, response) = try await request.getResponse(with: session)
        
        return response
    }
}
#endif

// MARK: - Displaying Customization -
extension ReadCupcake {
    var title: String {
        self.flavor
    }
    
    var description: String {
        "Made with " + self.ingredients.joined(separator: ", ") + "."
    }
}

// MARK: - Mocks -
#if DEBUG
import OrderedCollections
extension CreateOrReadCupcake {
    init() {
        id = .init()
        flavor = "Flavor \(Int.random(in: 1...100))"
        ingredients = ["Ingredient: \(Int.random(in: 1...10000))"]
        price = .random(in: 1...30)
        createdAt = .randomDate()
        imageName = "Image Name \(Int.random(in: 1...100))"
    }
    
    static var mocks: OrderedDictionary<UUID, CreateOrReadCupcake> {
        var cupcakesDictionary = OrderedDictionary<UUID, CreateOrReadCupcake>()
        
        for _ in 0..<10 {
            let newCupcake = CreateOrReadCupcake()
            cupcakesDictionary.updateValue(newCupcake, forKey: newCupcake.id)
        }
        
        return cupcakesDictionary
    }
}
#endif
