//
//  ImageResizer.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/25/25.
//

import SwiftUI

struct ImageResizer<Content: View>: View {
    let imageData: Data
    let size: CGSize
    @ViewBuilder var content: (Image) -> Content
    
    @State private var downscaledImage: Image?
    
    var body: some View {
        Group {
            if let downscaledImage {
                content(downscaledImage)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 10)
                    )
            } else {
                ProgressView()
            }
        }
        .frame(width: size.width, height: size.height)
        .onAppear {
            if downscaledImage == nil {
                self.downscaleImage()
            }
        }
    }
}

extension ImageResizer {
    private func downscaleImage() {
        Task.detached(priority: .high) {
            let image = Image(by: imageData, with: size)
          
            await MainActor.run {
                self.downscaledImage = image
            }
        }
    }
}


#Preview {
    let imageData = UIImage(resource: .appLogo).pngData()
    
    ImageResizer(imageData: imageData!, size: .midSizePicture) { image in
        image
            .resizable()
            .scaledToFit()
    }
}
