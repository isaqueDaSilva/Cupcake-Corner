//
//  ImageHandler.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/10/25.
//

import SwiftUI
import PhotosUI

@Observable
@MainActor
final class ImageHandler {
    private let logger = AppLogger(category: "ImageHandler")
    
    var initialCupcakeImage: CupcakeImage? = nil
    var cupcakeImage: CupcakeImage? = nil
    var insertState: ViewState = .default
    var pickerItemSelected: PhotosPickerItem? = nil {
        didSet {
            print(pickerItemSelected == nil)
            if let pickerItemSelected {
                self.getImage(with: pickerItemSelected)
            }
        }
    }
    
    private func getImage(with pickerItemSelected: PhotosPickerItem) {
        self.insertState = .loading
        
        pickerItemSelected.loadTransferable(type: Data.self) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let data):
                if let data {
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        self.cupcakeImage = .init(imageData: data)
                        self.insertState = .default
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    self.cupcakeImage = nil
                    self.logger.error("Could not possible to load image: \(error.localizedDescription)")
                    self.insertState = .default
                }
            }
        }
    }
    
    func sendImage(
        with cupcakeID: UUID,
        token: String,
        and session: URLSession
    ) async throws(AppError) {
        guard let cupcakeImage, self.cupcakeImage != self.initialCupcakeImage else {
            throw AppError(
                title: "No image",
                description: "You need a image to follow with this action."
            )
        }
        
        do {
            guard try await cupcakeImage.sendImage(
                    with: cupcakeID.uuidString,
                    token: token,
                    session: session
                ).status == .ok
            else {
                throw AppError.badResponse
            }
        } catch {
            self.logger.error(
                "Failed to set image for cupcake \(cupcakeID.uuidString) with error: \(error.localizedDescription)"
            )
            throw .init(title: "Failed to set image for this cupcake.", description: "")
        }
    }
    
    func updateImage(
        with cupcakeID: UUID,
        imageName: String,
        token: String,
        and session: URLSession = .shared
    ) async throws {
        try await self.sendImage(with: cupcakeID, token: token, and: session)
        await ImageCache.shared.removeImageData(withKey: imageName)
    }
    
    func loadImage(with name: String) {
        self.insertState = .loading
        
        Task {
            let imageData = await ImageCache.shared.imageData(withKey: name)
            
            guard let imageData else {
                return await MainActor.run { [weak self] in
                    guard let self else { return }
                    
                    self.insertState = .default
                }
            }
            
            await MainActor.run { [weak self] in
                guard let self else { return }
                let cupcakeImage = CupcakeImage(imageData: imageData)
                self.initialCupcakeImage = cupcakeImage
                self.cupcakeImage = cupcakeImage
                self.insertState = .default
            }
        }
    }
}
