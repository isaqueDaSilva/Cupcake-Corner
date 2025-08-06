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
        var error: AppAlert? = nil
        var isLoading = false
        
        var executionScheduler = [() -> Void]() {
            didSet {
                self.logger.info("Execution Scheduler was changed. There is \(self.executionScheduler.count) tasks inside it.")
            }
        }
        
        func create(
            isPerfomingAction: Bool,
            uploadPicture: @escaping (UUID, String, URLSession) async throws -> Void,
            action: @escaping (ReadCupcake) -> Void,
            session: URLSession = .shared
        ) {
            if !self.newCupcake.flavor.isEmpty &&
                !self.newCupcake.ingredients.isEmpty &&
                self.newCupcake.price > 0.1 &&
                self.executionScheduler.isEmpty
            {
                guard let token = TokenHandler.getTokenValue(with: .accessToken, isWithBearerValue: true) else {
                    self.error = .accessDenied
                    return
                }
                
                self.isLoading = true
                
                guard !isPerfomingAction else {
                    self.executionScheduler.append { [weak self] in
                        guard let self else { return }
                        
                        self.create(isPerfomingAction: false, uploadPicture: uploadPicture, action: action)
                    }
                    
                    return
                }
                
                Task { [weak self] in
                    guard let self else { return }
                    
                    do {
                        let cupcake = try await self.newCupcake.createCupcake(with: token, and: session)
                        
                        try await uploadPicture(cupcake.id, token, session)
                        
                        await MainActor.run {
                            action(cupcake)
                        }
                    } catch let error as AppAlert {
                        await self.setError(error)
                    }
                    
                    await MainActor.run { [weak self] in
                        guard let self else { return }
                        
                        self.isLoading = false
                    }
                }
            }
        }
        
        private func setError(_ error: AppAlert) async {
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.error = error
            }
        }
        
        init() { }
    }
}
