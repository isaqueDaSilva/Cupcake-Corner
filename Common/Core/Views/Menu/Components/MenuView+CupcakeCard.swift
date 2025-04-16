//
//  CupcakeCard.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 4/16/25.
//

import SwiftUI

extension MenuView {
    struct CupcakeCard: View {
        let flavor: String
        let coverImageData: Data
        
        var body: some View {
            GroupBox {
                ImageResizer(imageData: coverImageData, size: .midSizePicture) { image in
                    image
                        .resizable()
                        .scaledToFit()
                }
            } label: {
                Text(flavor)
                    .lineLimit(1)
            }
        }
    }
}
