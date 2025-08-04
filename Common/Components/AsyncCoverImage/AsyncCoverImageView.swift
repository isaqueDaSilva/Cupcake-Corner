//
//  AsyncCoverImageView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 7/3/25.
//

import SwiftUI

struct AsyncCoverImageView: View {
    @Bindable private var accessHandler: AccessHandler
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
            guard !accessHandler.isPerfomingAction else {
                self.viewModel.executionScheduler.append {
                    self.viewModel.setImage()
                }
                
                return
            }
            
            self.viewModel.setImage()
        }
        .onChange(of: accessHandler.isPerfomingAction) { oldValue, newValue in
            guard newValue, newValue != oldValue, !self.viewModel.executionScheduler.isEmpty else { return }
            
            for action in self.viewModel.executionScheduler {
                action()
            }
        }
    }
    
    init(imageName: String?, size: CGSize = .smallSize, accessHandler: AccessHandler) {
        self._viewModel = .init(initialValue: .init(imageName: imageName))
        self.size = size
        self._accessHandler = .init(accessHandler)
    }
}
