//
//  HistoryView+ViewModel.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 8/1/25.
//

import Foundation
import OrderedCollections

extension HistoryView {
    @Observable
    @MainActor
    final class ViewModel {
        private let logger = AppLogger(category: "HistoryView+ViewModel")
        
        private var pageMetadata = PageMetadata() {
            didSet {
                self.logger.info("Page metadata was changed: \(self.pageMetadata.description).")
            }
        }
        
        private var ordersDicitionary: OrderedDictionary<UUID, Order> = [:] {
            didSet {
                self.logger.info("Orders list was changed with \(self.ordersDicitionary.count) items.")
            }
        }
        
        var error: AppAlert? = nil {
            didSet {
                if let error {
                    self.logger.info(
                        "A new error was thrown. Error -> Title: \(error.title); Description: \(error.description)."
                    )
                }
            }
        }
        
        var viewState: ViewState = .default {
            didSet {
                self.logger.info("View state was changed for \(self.viewState) state.")
            }
        }
        
        var executionScheduler = [() -> Void]() {
            didSet {
                self.logger.info("Execution Scheduler was changed. There is \(self.executionScheduler.count) tasks inside it.")
            }
        }
        
        var isLoading: Bool {
            self.viewState == .loading ||
            self.viewState == .fetchingMore ||
            self.viewState == .refreshing
        }
        
        var orders: [Order] {
            self.ordersDicitionary.values.elements
        }
        
        var orderIndices: Range<Int> { self.ordersDicitionary.values.indices }
        
        func fetchPage(isPerfomingAction: Bool) {
            if self.orders.isEmpty && self.viewState == .default && self.executionScheduler.isEmpty {
                self.startLoad(with: .loading)
                
                guard !isPerfomingAction else {
                    self.executionScheduler.append { [weak self] in
                        guard let self else { return }
                        
                        self.fetchPage(isPerfomingAction: false)
                    }
                    
                    return
                }
                
                Task { [weak self] in
                    guard let self else { return }
                    
                    #if DEBUG
                    await self.fetchMocks()
                    #else
                    await self.fetch(page: 1, session: session)
                    #endif
                    
                    await MainActor.run { [weak self] in
                        guard let self else { return }
                        self.viewState = self.pageMetadata.isLoadedAll ? .loadedAll : .default
                    }
                }
            }
        }
        
        func fetchMorePages(isVisible: Bool, index: Int, isPerfomingAction: Bool) {
            if self.isValidToFetchMore(isVisible: isVisible, index: index)
                && self.executionScheduler.isEmpty && self.viewState == .default {
                
                self.startLoad(with: .fetchingMore)
                
                guard !isPerfomingAction else {
                    self.executionScheduler.append { [weak self] in
                        guard let self else { return }
                        
                        self.fetchMorePages(isVisible: isVisible, index: index, isPerfomingAction: false)
                    }
                    
                    return
                }
                
                Task { [weak self] in
                    guard let self else { return }
                    
                    let nextPage = self.pageMetadata.page + 1
                    
                    #if DEBUG
                    await self.fetchMocks()
                    #else
                    await self.fetch(page: nextPage, session: session)
                    #endif
                    
                    await MainActor.run { [weak self] in
                        guard let self else { return }
                        self.viewState = self.pageMetadata.isLoadedAll ? .loadedAll : .default
                    }
                }
            }
        }
        
        func refresh(isPerfomingAction: Bool) {
            if self.executionScheduler.isEmpty {
                self.resetOrderList()
                self.startLoad(with: .refreshing)
                
                guard !isPerfomingAction else {
                    self.executionScheduler.append { [weak self] in
                        guard let self else { return }
                        
                        self.refresh(isPerfomingAction: false)
                    }
                    
                    return
                }
                
                Task { [weak self] in
                    guard let self else { return }
                    
                    #if DEBUG
                    await self.fetchMocks()
                    #else
                    await self.fetch(page: 0, session: session)
                    #endif
                    
                    await MainActor.run { [weak self] in
                        guard let self else { return }
                        self.viewState = self.pageMetadata.isLoadedAll ? .loadedAll : .default
                    }
                }
            }
        }
        
        func startLoad(with state: ViewState) {
            self.viewState = state
        }
        
        private func isValidToFetchMore(isVisible: Bool, index: Int) -> Bool {
            let eightyPorcentIndex = Int((Double((self.orders.count - 1)) * 0.8).rounded(.up))
            let indexElementID = self.ordersDicitionary.values.elements[index].id
            let eightyPorcentIndexElementID = self.ordersDicitionary.values.elements[eightyPorcentIndex].id
            
            guard isVisible, self.orderIndices.indices.contains(eightyPorcentIndex),
                  indexElementID == eightyPorcentIndexElementID
            else {
                return false
            }
            
            return true
        }
        
        private func fetch(with currentPage: Int, and session: URLSession) async {
            do {
                guard let token = TokenHandler.getTokenValue(with: .accessToken, isWithBearerValue: true) else {
                    throw AppAlert.accessDenied
                }
                
                let ordersPage = try await Order.requestMorePages(
                    token: token,
                    currentPage: currentPage,
                    and: session
                )
                
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    
                    for order in Order.mocks {
                        self.ordersDicitionary.updateValue(order, forKey: order.id)
                    }
                    
                    self.pageMetadata = ordersPage.metadata
                }
            } catch let error as AppAlert {
                await self.setError(error)
            } catch {
                await self.setError(.init(title: "Failed to get orderList", description: ""))
            }
        }
        
        private func resetOrderList() {
            self.ordersDicitionary.removeAll()
            self.pageMetadata = .init()
        }
        
        private func setError(_ error: AppAlert) async {
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                self.error = error
                self.viewState = .default
            }
        }
    }
}

#if DEBUG
extension HistoryView.ViewModel {
    private func fetchMocks() async {
        do {
            try await Task.sleep(for: .seconds(4))
            
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                for order in Order.mocks {
                    self.ordersDicitionary.updateValue(order, forKey: order.id)
                }
                
                let page: Int = switch self.orders.count {
                case 10:
                    1
                case 20:
                    2
                case 30:
                    3
                default:
                    3
                }
                
                self.pageMetadata = .init(page: page, per: 10, total: 30)
            }
        } catch {
            await self.setError(.internalError)
        }
    }
}
#endif
