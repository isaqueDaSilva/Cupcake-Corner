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
    
    func fetchPage(session: URLSession = .shared) {
        guard self.isCupcakeListEmpty && self.viewState == .default else { return }
        
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
                self.viewState = self.cupcakes.count == self.pageMetadata.total ? .loadedAll : .default
            }
        }
    }
    
    func fetchMorePages(isVisible: Bool, index: Int, session: URLSession = .shared) {
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
                self.viewState = self.cupcakes.count == self.pageMetadata.total ? .loadedAll : .default
            }
        }
    }
    
    func refresh(session: URLSession = .shared) {
        Task { [weak self] in
            guard let self else { return }
            
            await self.resetCupcakeList()
            
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
            let token = try TokenHandler.getValue(key: .accessToken)
            
            let (data, response) = try await ReadCupcake.fetch(
                with: token,
                currentPage: page,
                and: session
            )
            
            try self.checkResponse(response)
            
            let cupcakesPage = try EncoderAndDecoder.decodeResponse(type: Page<ReadCupcake>.self, by: data)
            
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
    
    private func resetCupcakeList() async {
        await ImageCache.shared.removeAllImageData()
        
        await MainActor.run { [weak self] in
            guard let self else { return }
            
            self.cupcakes.removeAll()
            self.pageMetadata = .init()
            self.viewState = .refreshing
        }
    }
    
    private func checkResponse(_ response: Response) throws(AppAlert) {
        guard response.status == .ok else {
            throw .badResponse
        }
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
                
                self.pageMetadata = .init(total: 30)
            }
        } catch {
            await self.setError(.internalError)
        }
    }
}
#endif
