//
//  UpdateCupcakeView+ViewModel.swift
//  CupcakeCornerForAdmin
//
//  Created by Isaque da Silva on 3/11/25.
//

import ErrorWrapper
import Foundation
import NetworkHandler
import SwiftUI
import PhotosUI

extension UpdateCupcakeView {
    @Observable
    @MainActor
    final class ViewModel {
        private let cupcake: Cupcake
        
        var flavor: String
        var coverImageData: Data
        var ingredients: [String]
        var price: Double
        var ingredientName = ""
        
        var error: ExecutionError? = nil
        var isLoading = false
        
        var pickerItemSelected: PhotosPickerItem? = nil {
            didSet {
                if let pickerItemSelected {
                    getImage(pickerItemSelected)
                }
            }
        }
        
        private func getImage(_ pickerItemSelected: PhotosPickerItem) {
            GetPhoto.get(with: pickerItemSelected) { [weak self] imageData in
                guard let self else { return }
                
                if let imageData {
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.coverImageData = imageData
                    }
                }
            }
        }
        
        func update(
            with completation: @escaping (Cupcake) throws -> Void,
            session: URLSession = .shared
        ) {
            self.isLoading = true
            
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    let updatedCupcake = try makeUpdate()
                    let encodedUpdatedCupcake = try Network.encodeData(updatedCupcake)
                    let (data, response) = try await getData(with: encodedUpdatedCupcake, session: session)
                    try Network.checkResponse(response)
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    let cupcake = try Network.decodeResponse(type: Cupcake.self, by: data, with: decoder)
                    
                    await MainActor.run { [weak self] in 
                        guard let self else { return }
                        
                        do {
                            try completation(cupcake)
                        } catch {
                            self.error = error as? ExecutionError
                        }
                    }
                } catch let error as ExecutionError {
                    await setError(error)
                }
                
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
        
        private func makeUpdate() throws(ExecutionError) -> Cupcake.Update {
            let updatedFlavor = (self.cupcake.flavor != self.flavor) ? self.flavor : nil
            let updatedCoverImage = (self.cupcake.coverImage != self.coverImageData) ? self.coverImageData : nil
            let updatedIngredients = (
                !self.cupcake.ingredients.isEmpty && cupcake.ingredients != self.ingredients
            ) ? self.ingredients : nil
            let updatedPrice = (self.cupcake.price != self.price) ? self.price : nil
            
            guard let cupcakeID = cupcake.id else {
                throw .missingData
            }
            
            let updatedCupcake = Cupcake.Update(
                id: cupcakeID,
                flavor: updatedFlavor,
                coverImage: updatedCoverImage,
                ingredients: updatedIngredients,
                price: updatedPrice
            )
            
            return updatedCupcake
        }
        
        private func getData(
            with updatedCupcakeData: Data,
            session: URLSession
        ) async throws -> (Data, URLResponse) {
            let token = try TokenGetter.getValue()
            
            return try await Network.getData(
                path: EndpointBuilder.makePath(endpoint: .cupcake, path: .update),
                httpMethod: .patch,
                headers: [
                    EndpointBuilder.Header.authorization.rawValue : token,
                    EndpointBuilder.Header.contentType.rawValue : EndpointBuilder.HeaderValue.json.rawValue
                ],
                body: updatedCupcakeData,
                session: session
            )
        }
        
        private func setError(_ error: ExecutionError) async {
            await MainActor.run {
                self.error = error
            }
        }
        
        init(
            cupcake: Cupcake
        ) {
            self.cupcake = cupcake
            self.flavor = cupcake.flavor
            self.coverImageData = cupcake.coverImage
            self.ingredients = cupcake.ingredients
            self.price = cupcake.price
        }
    }
}
