//
//  AsyncCoverImageView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 7/3/25.
//

import SwiftUI

struct AsyncCoverImageView: View {
    private let imageName: String?
    private let logger = AppLogger(category: "AsyncCoverImageView")
    
    @State private var isLoading = false
    @State private var imageData: Data? = nil
    
    var body: some View {
        Group {
            switch isLoading {
            case true:
                ProgressView()
            case false:
                Image(
                    by: self.imageData,
                    with: .smallSize,
                    defaultIcon: .exclamationmarkTriangleFill
                )
                .resizable()
                .scaledToFit()
                .foregroundStyle(.yellow)
            }
        }
        .frame(
            maxWidth: CGSize.smallSize.width,
            maxHeight: CGSize.smallSize.height
        )
        .onAppear {
            self.dowloadImage()
        }
    }
    
    init(imageName: String?) {
        self.imageName = imageName
    }
}

extension AsyncCoverImageView {
    private func dowloadImage() {
        guard let imageName else { return }
        
        self.isLoading = true
        
        Task.detached(priority: .background) {
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
                
                let cupcakeImagedata = try JSONDecoder().decode(CupcakeImage.self, from: data)
                
                await MainActor.run {
                    self.imageData = cupcakeImagedata.imageData
                }
            } catch {
                self.logger.error(
                    "Could not possible to download Image with error: \(error.localizedDescription)"
                )
            }
            
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
}
