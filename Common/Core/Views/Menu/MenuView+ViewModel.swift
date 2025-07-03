//
//  MenuView+ViewModel.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import Foundation
import Observation

enum ViewState {
    case `default`, loading, loadedAll
}

extension MenuView {
    @Observable
    @MainActor
    final class ViewModel {
        var cupcakes: [ReadCupcake] = []
        private var pageMetadata = PageMetadata()
        var viewState: ViewState = .default
        var selectedCupcake: [ReadCupcake] = []
        var error: AppError?
        
        var isLoading: Bool {
            self.viewState == .loading
        }
        
        func removeCupcakes() {
            self.cupcakes.removeAll()
            self.viewState = .default
            self.pageMetadata = .init()
        }
        
        #if DEBUG
        func fechMocks(
            isRefreshing: Bool,
            session: URLSession = .shared
        ) async{
            print(viewState)
            
            guard viewState != .loadedAll else { return }
            
            self.viewState = cupcakes.isEmpty ? .loading : .default
            
            print("Starting...")
            do {
                try await Task.sleep(for: .seconds(4))
                
                print("Filling...")
                let cupcakes = self.cupcakes + ReadCupcake.mocks
                
                await MainActor.run {
                    self.cupcakes = cupcakes
                    print(self.cupcakes.count)
                }
            } catch {
                print(error.localizedDescription)
            }
            
            await MainActor.run { [weak self] in
                guard let self else { return }
                self.viewState = cupcakes.count < 30 ? .default : .loadedAll
                print(viewState)
            }
        }
        #endif
        
        func fetch(
            isRefresh: Bool = false,
            isFetchingMore: Bool = false,
            session: URLSession = .shared
        ) {
            //            if isFetchingMore {
            //                guard pageMetadata.page + 1 != pageMetadata.page else { return }
            //                self.isFetching = true
            //            } else {
            //                self.isLoading = true
            //            }
            //
            //            Task { [weak self] in
            //                guard let self else { return }
            //
            //                do {
            //                    let token = try TokenGetter.getValue()
            //
            //                    let (data, response) = try await ReadCupcake.fetch(
            //                        with: token,
            //                        currentPage: isRefresh ? 1 : pageMetadata.page,
            //                        and: session
            //                    )
            //
            //                    try self.checkResponse(response)
            //
            //                    let cupcakesPage = try EncoderAndDecoder.decodeResponse(type: Page<ReadCupcake>.self, by: data)
            //
            //                    await MainActor.run {
            //                        if isRefresh {
            //                            self.cupcakes = cupcakesPage.items
            //                        } else {
            //                            self.cupcakes += cupcakesPage.items
            //                        }
            //                        self.pageMetadata = cupcakesPage.metadata
            //                    }
            //                } catch let error as AppError {
            //                    await self.setError(error)
            //                }
            //
            //                await MainActor.run { [weak self] in
            //                    guard let self else { return }
            //                    if isFetchingMore {
            //                        self.isFetching = false
            //                    } else {
            //                        self.isLoading = false
            //                    }
            //                }
            //            }
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
        
        init(isPreview: Bool = false) {
            #if DEBUG
            //self.cupcakes = ReadCupcake.mocks
            #endif
        }
    }
}
