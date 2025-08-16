//
//  AsyncCoverImageView+ViewModel.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 7/5/25.
//

import Foundation

extension AsyncCoverImageView {
    @Observable
    @MainActor
    final class ViewModel {
        private let imageName: String?
        private let logger = AppLogger(category: "AsyncCoverImageView")
        private var setImageTask: Task<Void, Never>? = nil
        
        var executionScheduler = [() -> Void]() {
            didSet {
                self.logger.info("Execution Scheduler was changed. There is \(self.executionScheduler.count) tasks inside it.")
            }
        }
        
        var isLoading = false 
        var imageData: Data? = nil
        
        func startLoad() {
            self.isLoading = true
        }
        
        func setImage(isPerfomingAction: Bool) {
            if let imageName, self.executionScheduler.isEmpty {
                self.startLoad()
                
                guard !isPerfomingAction else {
                    self.executionScheduler.append { [weak self] in
                        guard let self else { return }
                        
                        self.setImage(isPerfomingAction: false)
                    }
                    
                    return
                }
                
                self.setImageTask = Task.detached { [weak self] in
                    guard let self else { return }
                    
                    if let imageData = await ImageCache.shared.imageData(withKey: imageName) {
                        await MainActor.run { [weak self] in
                            guard let self else { return }
                            
                            self.imageData = imageData
                        }
                    } else {
                        await self.dowloadImage(imageName: imageName)
                    }
                    
                    await MainActor.run { [weak self] in
                        guard let self else { return }
                        
                        self.isLoading = false
                        
                        self.setImageTask?.cancel()
                        self.setImageTask = nil
                    }
                }
            }
        }
        
        private func dowloadImage(imageName: String) async {
            do {
                guard let token = TokenHandler.getTokenValue(with: .accessToken, isWithBearerValue: true) else {
                    throw AppAlert.accessDenied
                }

                let cupcakeImagedata = try await CupcakeImage.getImage(
                    with: imageName,
                    token: token,
                    session: .shared
                )
                
                await ImageCache.shared.setImageData(cupcakeImagedata, forKey: imageName)
                
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    
                    self.imageData = cupcakeImagedata
                }
            } catch {
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    
                    self.logger.error(
                        "Could not possible to download Image with error: \(error.localizedDescription)"
                    )
                }
            }
        }
        
        init(imageName: String?) {
            self.imageName = imageName
        }
    }
}
