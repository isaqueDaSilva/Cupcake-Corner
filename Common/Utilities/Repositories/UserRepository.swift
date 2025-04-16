//
//  UserRepository.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import ErrorWrapper
import Foundation
import Observation
import SwiftData

@Observable
@MainActor
final class UserRepository {
    var user: User?
    
    func insert(
        _ userResult: User.Get,
        with context: ModelContext
    ) throws(ExecutionError) {
        let newUser = User(with: userResult)
        
        context.insert(newUser)
        
        do {
            try context.save()
            self.user = newUser
        } catch {
            throw .fetchFailed
        }
    }
    
    func load(with context: ModelContext) throws(ExecutionError) {
        let fetchDescriptor = FetchDescriptor<User>()
        guard let users = try? context.fetch(fetchDescriptor) else {
            throw .fetchFailed
        }
        
        guard users.isEmpty || users.count == 1 else {
            throw ExecutionError.modelQuantityDifferent
        }
        
        self.user = users.isEmpty ? nil : users[0]
    }
    
    func delete(with context: ModelContext) throws(ExecutionError) {
        guard let user else { throw .noItemSaved }
        
        context.delete(user)
        
        do {
            try context.save()
            self.user = nil
        } catch {
            throw .saveFailed
        }
    }
    
    deinit {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.user = nil
        }
    }
}
