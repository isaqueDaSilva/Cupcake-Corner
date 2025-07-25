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
        
        var isLoading = false
        var imageData: Data? = nil
        
        func setImage() {
            guard let imageName else { return }
            
            self.isLoading = true
            
            Task { [weak self] in
                guard let self else { return }
                
                if let imageData = await ImageCache.shared.imageData(withKey: imageName) {
                    self.imageData = imageData
                } else {
                    await self.dowloadImage(imageName: imageName)
                }
                
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
        
        private func dowloadImage(imageName: String) async {
            do {
                let token = try TokenGetter.getValue()

                let (data, response) = try await CupcakeImage.getImage(
                    with: imageName,
                    token: token,
                    session: .shared
                )

                guard response.status == .ok else {
                    throw AppError.badResponse
                }
                
                try await Task.sleep(for: .seconds(4))
                
                let cupcakeImagedata = try JSONDecoder().decode(CupcakeImage.self, from: data).imageData
                
                await ImageCache.shared.setImageData(cupcakeImagedata, forKey: imageName)
                
                await MainActor.run {
                    self.imageData = cupcakeImagedata
                }
            } catch {
                await MainActor.run {
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
