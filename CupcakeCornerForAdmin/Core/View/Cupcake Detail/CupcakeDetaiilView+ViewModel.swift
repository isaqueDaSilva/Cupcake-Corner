//
//  CupcakeDetaiilView+ViewModel.swift
//  CupcakeCornerForAdmin
//
//  Created by Isaque da Silva on 3/11/25.
//

import Foundation
import Observation

extension CupcakeDetailView {
    @Observable
    @MainActor
    final class ViewModel {
        var isLoading = false
        var isShowingDeleteAlert = false
        var error: AppError?
        var isShowingUpdateCupcakeView = false
        
        func deleteCupcake(
            cupcake: ReadCupcake,
            _ session: URLSession = .shared,
            completation: @escaping () -> Void
        ) {
            self.isLoading = true
            
            Task { [weak self] in
                guard let self else { return }
                
                do {
                    let token = try TokenGetter.getValue()
                    let response = try await cupcake.delete(with: token, and: session)
                    
                    try self.checkResponse(response)
                    
                    await MainActor.run {
                        completation()
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
        
        private func setError(_ error: AppError) async {
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                self.error = error
            }
        }
    }
}

