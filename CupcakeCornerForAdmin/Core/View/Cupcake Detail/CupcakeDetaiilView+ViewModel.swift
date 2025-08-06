//
//  CupcakeDetaiilView+ViewModel.swift
//  CupcakeCornerForAdmin
//
//  Created by Isaque da Silva on 3/11/25.
//

import Foundation

extension CupcakeDetailView {
    @Observable
    @MainActor
    final class ViewModel {
        private let logger = AppLogger(category: "CupcakeDetailView+ViewModel")
        
        var isLoading = false
        var isShowingDeleteAlert = false
        var error: AppAlert?
        var isShowingUpdateCupcakeView = false
        
        var executionScheduler = [() -> Void]() {
            didSet {
                self.logger.info("Execution Scheduler was changed. There is \(self.executionScheduler.count) tasks inside it.")
            }
        }
        
        func deleteCupcake(
            isPerfomingAction: Bool,
            cupcake: ReadCupcake,
            _ session: URLSession = .shared,
            completation: @escaping () -> Void
        ) {
            if self.executionScheduler.isEmpty {
                self.isLoading = true
                
                guard let token = TokenHandler.getTokenValue(with: .accessToken, isWithBearerValue: true) else {
                    self.error = .accessDenied
                    return
                }
                
                guard !isPerfomingAction else {
                    self.executionScheduler.append { [weak self] in
                        guard let self else { return }
                        
                        self.deleteCupcake(isPerfomingAction: false, cupcake: cupcake, completation: completation)
                    }
                    
                    return
                }
                
                Task { [weak self] in
                    guard let self else { return }
                    
                    do {
                        try await cupcake.delete(with: token, and: session)
                        
                        await MainActor.run {
                            completation()
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
    }
}

