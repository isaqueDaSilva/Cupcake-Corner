//
//  CoverImageView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/10/25.
//

import SwiftUI

/// Sets a default component to display the cupcake's cover image.
struct CoverImageView: View {
    @State private var coverImage: Image?
    
    /// The data representation of the image.
    let imageData: Data?
    
    /// The size that we want that the image will be displayed.
    let size: CGSize
    
    var body: some View {
        Group {
            if let coverImage {
                coverImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Icon.questionmarkDiamond.systemImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .onAppear {
            // Checks if already had an image defined at the `coverImage` property.
            guard coverImage == nil else { return }
            
            self.coverImage = .init(
                by: self.imageData,
                with: self.size,
                defaultIcon: .squareSlash
            )
        }
    }
    
    init(imageData: Data? = nil, size: CGSize) {
        self.imageData = imageData
        self.size = size
    }
}

#Preview {
    CoverImageView(size: .midHighPicture)
}
