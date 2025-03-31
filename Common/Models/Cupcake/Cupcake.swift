//
//  Cupcake.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import Foundation

struct Cupcake: Identifiable {
    let id: UUID?
    let flavor: String
    let coverImage: Data
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
#endif
