//
//  AsyncCoverImageView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 7/3/25.
//

import SwiftUI

struct AsyncCoverImageView: View {
    @State private var viewModel: ViewModel
    
    private let size: CGSize
    
    var body: some View {
        Group {
            switch viewModel.isLoading {
            case true:
                ProgressView()
            case false:
                Image(
                    by: self.viewModel.imageData,
                    with: .smallSize,
                    defaultIcon: .exclamationmarkTriangleFill
                )
                .resizable()
                .scaledToFit()
                .foregroundStyle(.yellow)
            }
        }
        .frame(
            maxWidth: self.size.width,
            maxHeight: self.size.height
        )
        .onAppear {
            self.viewModel.setImage()
        }
    }
    
    init(imageName: String?, size: CGSize = .smallSize) {
        self._viewModel = .init(initialValue: .init(imageName: imageName))
        self.size = size
    }
}
