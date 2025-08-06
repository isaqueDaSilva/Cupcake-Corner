//
//  MenuViewModel.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 4/16/25.
//

import Foundation
import OrderedCollections

@Observable
@MainActor
final class MenuViewModel {
    private let logger = AppLogger(category: "MenuViewModel")
    private var pageMetadata = PageMetadata()
    
    var cupcakes: OrderedDictionary<UUID, ReadCupcake> = [:] {
        didSet {
            self.logger.info("Cupcake storage update. Total of Items: \(self.cupcakes.count)")
        }
    }
    
    var viewState: ViewState = .default {
        didSet {
            self.logger.info("View state update for \(self.viewState) status.")
        }
    }
    
    var error: AppAlert? = nil {
        didSet {
            if let error {
                self.logger.info("An error was thrown. Error Description: \(error.description)")
            }
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
    
    var cupcakesIndicies: Range<Int> {
        self.cupcakes.values.indices
    }
    
    var isCupcakeListEmpty: Bool {
        self.cupcakes.isEmpty
    }
    
    func fetchPage(isPerfomingAction: Bool, session: URLSession = .shared) {
        if self.cupcakes.isEmpty && self.viewState == .default && self.executionScheduler.isEmpty {
            
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
                
                await ImageCache.shared.removeAllImageData()
                
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
    
    func fetchMorePages(isVisible: Bool, index: Int, isPerfomingAction: Bool, session: URLSession = .shared) {
        if self.isValidToFetchMore(isVisible: isVisible, index: index) && self.executionScheduler.isEmpty && self.viewState == .default {
            
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
                
                await MainActor.run {
                    self.viewState = self.cupcakes.count == self.pageMetadata.total ? .loadedAll : .default
                }
            }
        }
    }
    
    func refresh(isPerfomingAction: Bool, session: URLSession = .shared) {
        if self.executionScheduler.isEmpty {
            self.resetCupcakeList()
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
                
                await ImageCache.shared.removeAllImageData()
                
                #if DEBUG
                await self.fetchMocks()
                #else
                await self.fetch(page: 0, session: session)
                #endif
                
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.viewState = self.cupcakes.count == self.pageMetadata.total ? .loadedAll : .default
                }
            }
        }
    }
    
    func startLoad(with state: ViewState) {
        self.viewState = state
    }
    
    private func isValidToFetchMore(isVisible: Bool, index: Int) -> Bool {
        let eightyPorcentIndex = Int((Double((self.cupcakes.count - 1)) * 0.8).rounded(.up))
        
        guard isVisible, self.cupcakes.values.elements.indices.contains(eightyPorcentIndex),
              self.cupcakes.values.elements[index].id == self.cupcakes.values.elements[eightyPorcentIndex].id else {
            return false
        }
        
        return true
    }
    
    private func fetch(
        page: Int,
        session: URLSession = .shared
    ) async {
        do {
            guard let token = TokenHandler.getTokenValue(with: .accessToken, isWithBearerValue: true) else {
                throw AppAlert.accessDenied
            }
            
            let cupcakesPage = try await ReadCupcake.fetch(
                with: token,
                currentPage: page,
                and: session
            )
            
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                for cupcake in cupcakesPage.items {
                    self.cupcakes.updateValue(cupcake, forKey: cupcake.id)
                }
                
                self.pageMetadata = cupcakesPage.metadata
            }
        } catch let error as AppAlert {
            await self.setError(error)
        } catch {
            await self.setError(.init(title: "Failed to get cupcakes", description: error.localizedDescription))
        }
    }
    
    private func resetCupcakeList() {
        self.cupcakes.removeAll()
        self.pageMetadata = .init()
        self.viewState = .refreshing
    }
    
    private func setError(_ error: AppAlert) async {
        await MainActor.run { [weak self] in
            guard let self else { return }
            
            self.error = error
            self.viewState = .default
            self.logger.error(error.description)
        }
    }
}

#if DEBUG
extension MenuViewModel {
    private func fetchMocks() async {
        do {
            try await Task.sleep(for: .seconds(4))
            
            await MainActor.run { [weak self] in
                guard let self else { return }
                
                for cupcake in ReadCupcake.mocks {
                    self.cupcakes.updateValue(cupcake.value, forKey: cupcake.key)
                }
                
                let page: Int = switch self.cupcakes.count {
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
