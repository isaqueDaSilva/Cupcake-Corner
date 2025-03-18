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
        let cupcake: Cupcake
        
        var flavor: String
        var coverImageData: Data
        var ingredients: [String]
        var price: Double
        var ingredientName = ""
        
        var pickerItemSelected: PhotosPickerItem? = nil {
            didSet {
                if let pickerItemSelected {
                    getImage(pickerItemSelected)
                }
            }
        }
        
        var error: ExecutionError? = nil
        var isLoading = false
        
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
            with completation: @escaping (Cupcake) -> Void,
            session: URLSession = .shared
        ) {
            self.isLoading = true
            
            Task {
                do {
                    let updatedCupcake = try makeUpdate()
                    let encodedUpdatedCupcake = try encode(updatedCupcake)
                    let (data, response) = try await getData(with: encodedUpdatedCupcake, session: session)
                    try checkResponse(response)
                    let cupcake = try decodeCupcake(by: data)
                    
                    await MainActor.run {
                        completation(cupcake)
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
        
        private func encode(
            _ updatedCupcake: Cupcake.Update
        ) throws(ExecutionError) -> Data {
            do {
                return try JSONEncoder().encode(updatedCupcake)
            } catch {
                throw .encodeFailure
            }
        }
        
        private func getData(
            with updatedCupcakeData: Data,
            session: URLSession
        ) async throws -> (Data, URLResponse) {
            let token = try TokenGetter.getValue()
            
            let endpoint = Endpoint(
                scheme: EndpointBuilder.httpSchema,
                host: EndpointBuilder.domainName,
                path: EndpointBuilder.makePath(endpoint: .cupcake, path: .update),
                httpMethod: .post,
                headers: [
                    EndpointBuilder.Header.authorization.rawValue : token,
                    EndpointBuilder.Header.contentType.rawValue : EndpointBuilder.HeaderValue.json.rawValue
                ],
                body: updatedCupcakeData
            )
            
            let handler = NetworkHandler<ExecutionError>(
                endpoint: endpoint,
                session: session,
                unkwnonURLRequestError: .internalError,
                failureToGetDataError: .decodedFailure
            )
            
            return try await handler.getResponse()
        }
        
        private func checkResponse(_ response: URLResponse) throws(ExecutionError) {
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            
            guard let statusCode, statusCode == 200 else {
                throw .resposeFailed
            }
        }
        
        private func decodeCupcake(by data: Data) throws(ExecutionError) -> Cupcake {
            guard let cupcake = try? JSONDecoder().decode(Cupcake.self, from: data) else {
                throw .decodedFailure
            }
            
            return cupcake
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
