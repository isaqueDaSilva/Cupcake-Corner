//
//  UpdateCupcakeView+ViewModel.swift
//  CupcakeCornerForAdmin
//
//  Created by Isaque da Silva on 3/11/25.
//

import Foundation
import Observation

extension UpdateCupcakeView {
    @Observable
    @MainActor
    final class ViewModel {
        private let logger = AppLogger(category: "UpdateCupcakeView+ViewModel")
        
        var cupcake: ReadCupcake
        var flavor: String
        var ingredients: [String]
        var price: Double
        var ingredientName = ""
        
        var error: AppError? = nil
        var isLoading = false
        
        func update(
            session: URLSession = .shared,
            uploadPicture: @escaping (UUID, String, URLSession) async throws -> Void,
            action: @escaping (ReadCupcake?) -> Void
        ) {
            self.isLoading = true
            
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    let token = try TokenGetter.getValue()
                    
                    guard let id = cupcake.id else { throw AppError.missingData }
                    
                    let updatedCupcakeJSON = self.makeUpdate(for: self.cupcake)
                    
                    let updatedCupcake = try await self.updateCupcake(
                        updatedCupcakeJSON: updatedCupcakeJSON,
                        token: token,
                        session: session
                    )
                    
                    try await uploadPicture(id, token, session)
                    
                    await MainActor.run {
                        action(updatedCupcake)
                    }
                } catch let error as AppError {
                    await self.setError(error)
                }
                
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
        
        private func makeUpdate(for cupcake: CreateOrReadCupcake) -> [CreateOrReadCupcake.Key.RawValue: Any] {
            var keysAndValues: [CreateOrReadCupcake.Key.RawValue: Any] = [:]
            
            if cupcake.flavor != self.flavor {
                keysAndValues[CreateOrReadCupcake.Key.flavor.rawValue] = self.flavor
            }
            
            if !cupcake.ingredients.isEmpty && cupcake.ingredients != self.ingredients {
                keysAndValues[CreateOrReadCupcake.Key.ingredients.rawValue] = self.ingredients
            }
            
            if cupcake.price > 0.1 && cupcake.price != self.price {
                keysAndValues[CreateOrReadCupcake.Key.price.rawValue] = self.price
            }
            
            return keysAndValues
        }
        
        private func updateCupcake(
            updatedCupcakeJSON: [CreateOrReadCupcake.Key.RawValue : Any],
            token: String,
            session: URLSession
        ) async throws -> ReadCupcake? {
            guard !updatedCupcakeJSON.isEmpty else { return nil }
            
            let (data, response) = try await self.cupcake.update(
                keysAndValues: updatedCupcakeJSON,
                token: token,
                and: session
            )
            
            try checkResponse(response)
            
            let updatedCupcake = try EncoderAndDecoder.decodeResponse(type: ReadCupcake.self, by: data)
            
            return updatedCupcake
        }
        
        private func checkResponse(_ response: Response) throws(AppError) {
            guard response.status == .ok else {
                throw .badResponse
            }
        }
        
        private func setError(_ error: AppError) async {
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                self.error = error
            }
        }
        
        init(
            cupcake: ReadCupcake
        ) {
            self.cupcake = cupcake
            self.flavor = cupcake.flavor
            self.ingredients = cupcake.ingredients
            self.price = cupcake.price
        }
    }
}
