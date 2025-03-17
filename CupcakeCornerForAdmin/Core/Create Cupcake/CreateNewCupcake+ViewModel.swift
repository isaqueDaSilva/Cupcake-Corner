//
//  CreateNewCupcake+ViewModel.swift
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

extension CreateNewCupcake {
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
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.coverImageData = imageData
                    }
                }
            }
        }
        
        func create(
            with completationHandler: @escaping (Cupcake) -> Void,
            session: URLSession = .shared
        ) {
            self.isLoading = true
            
            Task {
                do {
                    let newCupcake = try setNewCupcake()
                    
                    let newCupcakeData = try encodeNewCupcake(newCupcake)
                    
                    let (data, response) = try await getData(
                        with: newCupcakeData,
                        session: session
                    )
                    
                    try checkResponse(response)
                    
                    let cupcake = try decodeCupcake(by: data)
                    
                    await MainActor.run {
                        completationHandler(cupcake)
                    }
                } catch let error as ExecutionError {
                    await setError(error)
                }
                
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
        
        private func setNewCupcake() throws(ExecutionError) -> Cupcake {
            guard let coverImageData else {
                throw .init(title: "Missing Photos", descrition: "")
            }
            
            let newCupcake = Cupcake(
                id: nil,
                flavor: self.flavor,
                coverImage: coverImageData,
                ingredients: self.ingredients,
                price: self.price,
                createAt: nil
            )
            
            return newCupcake
        }
        
        private func encodeNewCupcake(
            _ newCupcake: Cupcake
        ) throws(ExecutionError) -> Data {
            do {
                return try JSONEncoder().encode(newCupcake)
            } catch {
                throw .encodeFailure
            }
        }
        
        private func getData(
            with newCupcakeData: Data,
            session: URLSession
        ) async throws -> (Data, URLResponse) {
            let token = try TokenGetter.getValue()
            
            let endpoint = Endpoint(
                scheme: EndpointBuilder.httpSchema,
                host: EndpointBuilder.domainName,
                path: EndpointBuilder.makePath(endpoint: .cupcake, path: .create),
                httpMethod: .post,
                headers: [
                    EndpointBuilder.Header.authorization.rawValue : token,
                    EndpointBuilder.Header.contentType.rawValue : EndpointBuilder.HeaderValue.json.rawValue
                ],
                body: newCupcakeData
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
    }
}
