//
//  Cupcake.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import Foundation

typealias CreateCupcake = CreateOrReadCupcake
typealias ReadCupcake = Cupcake

struct CreateOrReadCupcake: Identifiable {
    let id: UUID?
    var flavor: String
    var imageName: String?
    var ingredients: [String]
    var price: Double
    let createdAt: Date?
    
    #if ADMIN
    init(flavor: String = "", ingredients: [String] = [], price: Double = 0.0) {
        self.id = nil
        self.flavor = flavor
        self.imageName = nil
        self.ingredients = ingredients
        self.price = price
        self.createdAt = nil
    }
    #endif
}

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

#if ADMIN
extension CreateCupcake {
    private func checkIfIsValid() throws(AppError) {
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
    ) async throws -> (Data, Response) {
        try self.checkIfIsValid()
        
        let cupcakeData = try EncoderAndDecoder.encodeData(self)
        
        let request = _Network(
            method: .post,
            scheme: .https,
            path: "/cupcake/create",
            fields: [
                .authorization : token,
                .contentType : _Network.HeaderValue.json.rawValue
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
    ) async throws -> Response {
        guard let id else { throw AppError.missingData }
        
        let updatedCupcakeData = try JSONSerialization.data(withJSONObject: json)
        
        let request = _Network(
            method: .patch,
            scheme: .https,
            path: "/cupcake/update/\(id.uuidString)",
            fields: [
                .authorization : token,
                .contentType : _Network.HeaderValue.json.rawValue
            ],
            requestType: .upload(updatedCupcakeData)
        )
        
        let (_, response) = try await request.getResponse(with: session)
        
        return response
    }
    
    func delete(with token: String, and session: URLSession) async throws -> Response {
        guard let id else { throw AppError.missingData }
        
        let request = _Network(
            method: .patch,
            scheme: .https,
            path: "/cupcake/delete/\(id.uuidString)",
            fields: [
                .authorization : token,
                .contentType : _Network.HeaderValue.json.rawValue
            ],
            requestType: .get
        )
        
        let (_, response) = try await request.getResponse(with: session)
        
        return response
    }
}
#endif

struct Cupcake: Identifiable {
    let id: UUID?
    let flavor: String
    let coverImage: Data
    var imageName: String?
    let ingredients: [String]
    let price: Double
    let createdAt: Date?
    
    init(
        id: UUID? = nil,
        flavor: String,
        coverImage: Data,
        ingredients: [String],
        price: Double,
        createAt: Date? = nil
    ) {
        self.id = id
        self.flavor = flavor
        self.coverImage = coverImage
        self.ingredients = ingredients
        self.price = price
        self.createdAt = createAt
        imageName = nil
    }
}

extension Cupcake: Codable {
    enum CodingKeys: CodingKey {
        case id
        case flavor
        case coverImage
        case ingredients
        case price
        case createdAt
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encodeIfPresent(self.flavor, forKey: .flavor)
        try container.encodeIfPresent(self.coverImage, forKey: .coverImage)
        try container.encodeIfPresent(self.ingredients, forKey: .ingredients)
        try container.encodeIfPresent(self.price, forKey: .price)
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.flavor = try container.decode(String.self, forKey: .flavor)
        self.coverImage = try container.decode(Data.self, forKey: .coverImage)
        self.ingredients = try container.decode([String].self, forKey: .ingredients)
        self.price = try container.decode(Double.self, forKey: .price)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        imageName = nil
    }
}

extension Cupcake: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(flavor)
        hasher.combine(createdAt)
    }
}

#if DEBUG
// MARK: - Sample -
import SwiftUI
extension Cupcake {
    
    init() {
        var imageData: Data {
            let image = UIImage(systemName: Icon.pencil.rawValue)
            
            return image?.pngData() ?? .init()
        }
        
        id = .init()
        flavor = "Flavor \(Int.random(in: 1...100))"
        coverImage = imageData
        ingredients = ["Ingredient: \(Int.random(in: 1...10000))"]
        price = .random(in: 1...30)
        createdAt = .randomDate()
        imageName = nil
    }
    
    static let mocks: [UUID: Cupcake] = {
        var cupcakesDictionary = [UUID: Cupcake]()
        
        for _ in 0..<10 {
            let newCupcake = Cupcake()
            cupcakesDictionary.updateValue(newCupcake, forKey: newCupcake.id!)
        }
        
        return cupcakesDictionary
    }()
}

extension CreateOrReadCupcake {
    
    init() {
        id = .init()
        flavor = "Flavor \(Int.random(in: 1...100))"
        ingredients = ["Ingredient: \(Int.random(in: 1...10000))"]
        price = .random(in: 1...30)
        createdAt = .randomDate()
        imageName = "Image Name \(Int.random(in: 1...100))"
    }
    
    static let mocks: [UUID: CreateOrReadCupcake] = {
        var cupcakesDictionary = [UUID: CreateOrReadCupcake]()
        
        for _ in 0..<10 {
            let newCupcake = CreateOrReadCupcake()
            cupcakesDictionary.updateValue(newCupcake, forKey: newCupcake.id!)
        }
        
        return cupcakesDictionary
    }()
}
#endif
