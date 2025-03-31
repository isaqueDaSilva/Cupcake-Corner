//
//  ModelContext+Extension.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//


#if DEBUG
import Foundation
import SwiftData

extension ModelContext {
    static let inMemoryModelContext: ModelContext = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: User.self, configurations: config)
        let context = ModelContext(container)
        
        context.insert(User.mock)
        try? context.save()
        
        return context
    }()
}
#endif
