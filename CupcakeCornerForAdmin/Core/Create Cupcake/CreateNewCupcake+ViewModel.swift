//
//  CreateNewCupcakeView+ViewModel.swift
//  CupcakeCornerForAdmin
//
//  Created by Isaque da Silva on 3/10/25.
//

import ErrorWrapper
import Foundation
import NetworkHandler
import Observation
import PhotosUI
import SwiftUI

extension CreateNewCupcakeView {
    @Observable
    @MainActor
    final class ViewModel {
        var flavor = ""
        var coverImageData: Data? = nil
        var ingredients: [String] = []
        var price: Double = 0
        var error: ExecutionError? = nil
        var isLoading = false
        
        var pickerItemSelected: PhotosPickerItem? = nil {
           didSet {
               if let pickerItemSelected {
                   getImage(pickerItemSelected)
               }
           }
       }
        
        private func getImage(_ itemSelected: PhotosPickerItem) {
            GetPhoto.get(with: itemSelected) { [weak self] imageData in
                guard let self else { return }
                
                if let imageData {
                    self.coverImageData = imageData
                }
            }
        }
        
        func create(
            with completationHandler: @escaping (Cupcake) -> Void,
            session: URLSession = .shared
        ) {
            self.isLoading = true
            
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    let newCupcake = try setNewCupcake()
                    
                    let newCupcakeData = try Network.encodeData(newCupcake)
                    
                    let (data, response) = try await getData(
                        with: newCupcakeData,
                        session: session
                    )
                    
                    try Network.checkResponse(response)
                    
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    let cupcake = try Network.decodeResponse(type: Cupcake.self, by: data, with: decoder)
                    
                    await MainActor.run {
                        completationHandler(cupcake)
                    }
                } catch let error as ExecutionError {
                    await setError(error)
                }
                
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    
                    self.isLoading = false
                }
            }
        }
        
        private func setNewCupcake() throws(ExecutionError) -> Cupcake {
            guard let coverImageData else {
                throw .init(title: "Missing the cover image", descrition: "")
            }
            
            let newCupcake = Cupcake(
                id: nil,
                flavor: self.flavor,
                coverImage: coverImageData,
                ingredients: self.ingredients,
                price: self.price
            )
            
            return newCupcake
        }
        
        private func getData(
            with newCupcakeData: Data,
            session: URLSession
        ) async throws -> (Data, URLResponse) {
            let token = try TokenGetter.getValue()
            
            return try await Network.getData(
                path: EndpointBuilder.makePath(endpoint: .cupcake, path: .create),
                httpMethod: .post,
                headers: [
                    EndpointBuilder.Header.authorization.rawValue : token,
                    EndpointBuilder.Header.contentType.rawValue : EndpointBuilder.HeaderValue.json.rawValue
                ],
                body: newCupcakeData,
                session: session
            )
        }
        
        private func setError(_ error: ExecutionError) async {
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.error = error
            }
        }
    }
}
