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
        private var pageMetadata = PageMetadata()
        private var ordersDicitionary: OrderedDictionary<UUID, Order> = [:]
        var currentViewState = ViewState.default
        var error: AppAlert? = nil
        var viewState: ViewState = .default
        
        var isLoading: Bool {
            self.viewState == .loading ||
            self.viewState == .fetchingMore ||
            self.viewState == .refreshing
        }
        
        var orders: [Order] {
            self.ordersDicitionary.values.elements
        }
        
        var orderIndices: Range<Int> { self.ordersDicitionary.values.indices }
        
        func fetchPage() {
            guard self.orders.isEmpty && self.viewState == .default else { return }
            
            self.viewState = .loading
            
            Task { [weak self] in
                guard let self else { return }
                
                await ImageCache.shared.removeAllImageData()
                
                #if DEBUG
                await self.fetchMocks()
                #else
                await self.fetch(page: 1, session: session)
                #endif
                
                await MainActor.run {
                    self.viewState = self.orders.count == self.pageMetadata.total ? .loadedAll : .default
                }
            }
        }
        
        func fetchMorePages(isVisible: Bool, index: Int) {
            guard viewState == .default && self.isValidToFetchMore(isVisible: isVisible, index: index) else { return }
            
            self.viewState = .fetchingMore
            
            Task { [weak self] in
                guard let self else { return }
                
                let nextPage = self.pageMetadata.page + 1
                
                #if DEBUG
                await self.fetchMocks()
                #else
                await self.fetch(page: nextPage, session: session)
                #endif
                
                await MainActor.run {
                    self.viewState = self.orders.count == self.pageMetadata.total ? .loadedAll : .default
                }
            }
        }
        
        func refresh() {
            Task { [weak self] in
                guard let self else { return }
                
                await self.resetOrderList()
                
                #if DEBUG
                await self.fetchMocks()
                #else
                await self.fetch(page: 0, session: session)
                #endif
                
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.viewState = self.orders.count == self.pageMetadata.total ? .loadedAll : .default
                }
            }
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
                let token = try TokenHandler.getValue(key: .accessToken)
                
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
        
        private func resetOrderList() async {
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                self.ordersDicitionary.removeAll()
                self.pageMetadata = .init()
                self.viewState = .refreshing
            }
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
                
                self.pageMetadata = .init(total: 30)
            }
        } catch {
            await self.setError(.internalError)
        }
    }
}
#endif
