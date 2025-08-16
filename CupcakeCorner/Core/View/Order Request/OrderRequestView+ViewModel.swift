//
//  OrderRequestView+ViewModel.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/10/25.
//

import Foundation

extension OrderRequestView {
    @Observable
    @MainActor
    final class ViewModel {
        private let logger = AppLogger(category: "OrderRequestView+ViewModel")
        private let basePrice: Double
        private var makeOrderTask: Task<Void, Never>? = nil
        
        var quantity = 1
        
        var isLoading = false
        var isSuccessed = false
        var alert: AppAlert? = nil
        
        var executionScheduler = [() -> Void]() {
            didSet {
                self.logger.info("Execution Scheduler was changed. There is \(self.executionScheduler.count) tasks inside it.")
            }
        }
        
        var finalPrice: Double {
            basePrice * Double(quantity)
        }
        
        func makeOrder(with cupcakeID: UUID?, isPerfomingAction: Bool, session: URLSession = .shared) {
            if let cupcakeID, self.executionScheduler.isEmpty {
                self.isLoading = true
                
                guard !isPerfomingAction else {
                    self.executionScheduler.append { [weak self] in
                        guard let self else { return }
                        
                        self.makeOrder(with: cupcakeID, isPerfomingAction: false)
                    }
                    
                    return
                }
                
                self.makeOrderTask = Task.detached { [weak self] in
                    guard let self else { return }
                    
                    do {
                        guard let token = TokenHandler.getTokenValue(with: .accessToken, isWithBearerValue: true) else {
                            throw AppAlert.accessDenied
                        }
                        
                        try await Order(quantity: self.quantity, finalPrice: self.finalPrice).create(
                            with: token,
                            cupcakeID: cupcakeID,
                            session: session
                        )
                        
                        await self.setAlert(
                            .init(
                                title: "Order Sent with Success",
                                description: "Go to the bag and track the progress of your order in real time."
                            ),
                            isSuccessed: true
                        )
                    } catch {
                        await self.setAlert(
                            .init(
                                title: "Failed to Ordered a Cupcake.",
                                description: "Try again or contact us to solve this problem."
                            ),
                            isSuccessed: false
                        )
                    }
                    
                    await MainActor.run { [weak self] in
                        guard let self else { return }
                        
                        self.makeOrderTask?.cancel()
                        self.makeOrderTask = nil
                    }
                }
            }
        }
        
        private func setAlert(_ alert: AppAlert, isSuccessed: Bool) async {
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.isLoading = false
                self.isSuccessed = isSuccessed
                self.alert = alert
            }
        }
        
        init(with price: Double) {
            self.basePrice = price
        }
    }
}
