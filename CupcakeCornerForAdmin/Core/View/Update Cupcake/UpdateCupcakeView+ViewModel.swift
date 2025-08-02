//
//  UpdateCupcakeView+ViewModel.swift
//  CupcakeCornerForAdmin
//
//  Created by Isaque da Silva on 3/11/25.
//

import Foundation

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
        
        var error: AppAlert? = nil
        var isLoading = false
        
        func update(
            session: URLSession = .shared,
            uploadPicture: @escaping (_ cupcakeID: UUID, _ imageName: String, _ token: String) async throws -> Void,
            action: @escaping (ReadCupcake?) -> Void
        ) {
            self.isLoading = true
            
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    guard let token = try TokenHandler.getTokenValue(with: .accessToken, isWithBearerValue: true) else {
                        throw AppAlert.accessDenied
                    }
                    
                    let updatedCupcakeJSON = self.makeUpdate(for: self.cupcake)
                    
                    let updatedCupcake = try await self.updateCupcake(
                        updatedCupcakeJSON: updatedCupcakeJSON,
                        token: token,
                        session: session
                    )
                    
                    if let updatedCupcake, let imageName = updatedCupcake.imageName {
                        try await uploadPicture(updatedCupcake.id, imageName, token)
                    }
                    
                    await MainActor.run {
                        action(updatedCupcake)
                    }
                } catch let error as AppAlert {
                    await self.setError(error)
                }
                
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
        
        private func makeUpdate(for cupcake: ReadCupcake) -> [ReadCupcake.Key.RawValue: Any] {
            var keysAndValues: [ReadCupcake.Key.RawValue: Any] = [:]
            
            if !cupcake.flavor.isEmpty && cupcake.flavor != self.flavor {
                keysAndValues[ReadCupcake.Key.flavor.rawValue] = self.flavor
            }
            
            if !cupcake.ingredients.isEmpty && cupcake.ingredients != self.ingredients {
                keysAndValues[ReadCupcake.Key.ingredients.rawValue] = self.ingredients
            }
            
            if cupcake.price > 0.1 && cupcake.price != self.price {
                keysAndValues[ReadCupcake.Key.price.rawValue] = self.price
            }
            
            return keysAndValues
        }
        
        private func updateCupcake(
            updatedCupcakeJSON: [ReadCupcake.Key.RawValue : Any],
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
        
        private func checkResponse(_ response: Response) throws(AppAlert) {
            guard response.status == .ok else {
                throw .badResponse
            }
        }
        
        private func setError(_ error: AppAlert) async {
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
