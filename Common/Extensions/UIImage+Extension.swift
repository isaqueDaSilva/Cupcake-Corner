//
//  UIImage+Extension.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/10/25.
//

import UIKit

extension UIImage {
    func resizer(with newSize: CGSize) -> UIImage {
        let aspectSize = self.size.aspectToFit(size)
        
        let renderer = UIGraphicsImageRenderer(size: aspectSize)
        
        let resizedImage = renderer.image { context in
            self.draw(in: .init(origin: .zero, size: aspectSize))
        }
        
        return resizedImage
    }
}
