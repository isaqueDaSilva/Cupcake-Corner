//
//  CoverImageView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/10/25.
//

import SwiftUI

/// Sets a default component to display the cupcake's cover image.
struct CoverImageView: View {
    @Binding var cupcakeImage: CupcakeImage?
    @Binding var insertCupcakeState: ViewState
    let size: CGSize
    
    var body: some View {
        Group {
            switch insertCupcakeState {
            case .default:
                self.defaultImageState
            case .loading:
                ProgressView()
            default:
                EmptyView()
            }
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

extension CoverImageView {
    private var defaultImageState: some View {
        if let cupcakeImage {
            Image(
                by: cupcakeImage.imageData,
                with: self.size,
                defaultIcon: .questionmarkDiamond
            )
            .resizable()
            .aspectRatio(contentMode: .fit)
        } else {
            Icon.photoOnRectangle.systemImage
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}

#Preview {
    CoverImageView(
        cupcakeImage: .constant(nil),
        insertCupcakeState: .constant(.default),
        size: .midSizePicture
    )
}
