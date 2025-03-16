//
//  Image+Extension.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/10/25.
//

import SwiftUI

extension Image {
    init(by data: Data, with size: CGSize) {
        let uiImage = UIImage(data: data)
        let resizedImage = uiImage?.resizer(with: size)
        
        if let resizedImage {
            self.init(uiImage: resizedImage)
        } else {
            self.init(systemName: Icon.exclamationmarkTriangleFill.rawValue)
        }
    }
    
    init(by data: Data?, with size: CGSize, defaultIcon: Icon) {
        guard let data else {
            self.init(systemName: defaultIcon.rawValue)
            return
        }
        
        self.init(by: data, with: size)
    }
    
    init(by imageResource: ImageResource, with size: CGSize) {
        let uiImage = UIImage(resource: imageResource)
        
        self.init(by: uiImage.pngData(), with: size, defaultIcon: .exclamationmarkTriangleFill)
    }
}
