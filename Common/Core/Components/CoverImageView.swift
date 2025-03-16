//
//  CoverImageView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/10/25.
//

import SwiftUI

struct CoverImageView: View {
    var coverImage: Image
    
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        coverImage
            .resizable()
            .scaledToFit()
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    init(
        imageData: Data? = nil,
        size: CGSize
    ) {
        self.coverImage = .init(by: imageData, with: size, defaultIcon: .squareSlash)
        self.width = size.width
        self.height = size.height
    }
}

#Preview {
    CoverImageView(size: .midHighPicture)
}
