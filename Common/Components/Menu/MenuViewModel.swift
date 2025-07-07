//
//  MenuViewModel.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 4/16/25.
//

import Foundation
import Observation

@Observable
@MainActor
final class MenuViewModel {
    private let logger = AppLogger(category: "MenuViewModel")
    private var pageMetadata = PageMetadata()
    
    var cupcakes: [ReadCupcake] = []
    var viewState: ViewState = .default
    var error: AppError?
    
    var isLoading: Bool {
        self.viewState == .loading ||
        self.viewState == .fetchingMore ||
        self.viewState == .refreshing
    }
    
    var isCupcakeListEmpty: Bool {
        self.cupcakes.isEmpty
    }
    
    var cupcakeListIndexRange: Range<Int> { 0..<self.cupcakes.count }
    
    func fetchPage(session: URLSession = .shared) {
        guard self.isCupcakeListEmpty && self.viewState == .default else { return }
        
        self.viewState = .loading
        
        Task { [weak self] in
            guard let self else { return }
            
            await ImageCache.shared.removeAllImageData()
            
            #if DEBUG
            await self.fetchMocks()
            #else
            await fetch(page: 0, session: session)
            #endif
        }
    }
    
    func fetchMorePages(session: URLSession = .shared) {
        guard viewState == .default else { return }
        
        self.viewState = .fetchingMore
        
        Task { [weak self] in
            guard let self else { return }
            
            let nextPage = self.pageMetadata.page + 1
            
            #if DEBUG
            await self.fetchMocks()
            #else
            await self.fetch(page: nextPage, session: session)
            #endif
        }
    }
    
    func refresh(session: URLSession = .shared) {
        Task {
            await self.resetCupcakeList()
            
            #if DEBUG
            await self.fetchMocks()
            #else
            await self.fetch(page: 0, session: session)
            #endif
        }
    }
    
    private func fetch(
        page: Int,
        session: URLSession = .shared
    ) async {
        do {
            let token = try TokenGetter.getValue()
            
            let (data, response) = try await ReadCupcake.fetch(
                with: token,
                currentPage: page,
                and: session
            )
            
            try self.checkResponse(response)
            
            let cupcakesPage = try EncoderAndDecoder.decodeResponse(type: Page<ReadCupcake>.self, by: data)
            
            await MainActor.run {
                self.cupcakes += cupcakesPage.items
                self.pageMetadata = cupcakesPage.metadata
                self.viewState = self.cupcakes.count == self.pageMetadata.total ? .loadedAll : .default
            }
        } catch let error as AppError {
            await self.setError(error)
        } catch {
            await self.setError(.init(title: "Failed to get cupcakes", descrition: error.localizedDescription))
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
    
    private func checkResponse(_ response: Response) throws(AppError) {
        guard response.status == .ok else {
            throw .badResponse
        }
    }
    
    private func setError(_ error: AppError) async {
        await MainActor.run { [weak self] in
            guard let self else { return }
            
            self.error = error
            self.viewState = .default
            self.logger.error(error.descrition)
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
                print("Filling...")
                self.cupcakes += ReadCupcake.mocks
                print("Filled with \(self.cupcakes.count) cupcakes.")
                self.viewState = cupcakes.count < 30 ? .default : .loadedAll
                print("View State:", viewState)
            }
        } catch {
            await self.setError(.internalError)
        }
    }
}
#endif
