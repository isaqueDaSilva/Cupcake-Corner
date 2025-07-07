//
//  CreateNewCupcakeView+ViewModel.swift
//  CupcakeCornerForAdmin
//
//  Created by Isaque da Silva on 3/10/25.
//

import Foundation
import Observation

extension CreateNewCupcakeView {
    @Observable
    @MainActor
    final class ViewModel {
        private let logger = AppLogger(category: "CreateNewCupcake+ViewModel")
        
        var newCupcake = CreateOrReadCupcake(flavor: "", ingredients: [], price: 0.0)
        var error: AppError? = nil
        var isLoading = false
        
        func create(
            uploadPicture: @escaping (UUID, String, URLSession) async throws -> Void,
            action: @escaping (ReadCupcake) -> Void,
            session: URLSession = .shared
        ) {
            self.isLoading = true
            
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    let token = try TokenGetter.getValue()
                    let (data, response) = try await self.newCupcake.createCupcake(with: token, and: session)
                    
                    try self.checkResponse(response)
                    
                    let cupcake = try self.decodeResponse(from: data)
                    
                    guard let id = cupcake.id else {
                        self.logger.info("Missing the id of the cupcake.")
                        throw AppError.missingData
                    }
                    
                    try await uploadPicture(id, token, session)
                    
                    await MainActor.run {
                        action(cupcake)
                    }
                } catch let error as AppError {
                    await self.setError(error)
                }
                
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    
                    self.isLoading = false
                }
            }
        }
        
        private func checkResponse(_ response: Response) throws(AppError) {
            guard response.status == .ok else {
                throw .badResponse
            }
        }
        
        private func decodeResponse(from data: Data) throws -> ReadCupcake {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            return try EncoderAndDecoder.decodeResponse(type: ReadCupcake.self, by: data)
        }
        
        private func setError(_ error: AppError) async {
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.error = error
            }
        }
        
        init() { }
    }
}
