//
//  CGSize+Extension.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/10/25.
//

import CoreGraphics

extension CGSize {
    func aspectToFit(_ size: CGSize) -> CGSize {
        let scaleX = size.width / self.width
        let scaleY = size.height / self.height
        
        let aspectRatio = min(scaleX, scaleY)
        
        let width = aspectRatio * self.width
        let height = aspectRatio * self.height
        
        return .init(width: width, height: height)
    }
    
    static let smallSize = CGSize(width: 60, height: 60)
    static let midSizePicture = CGSize(width: 100, height: 100)
    static let midHighPicture = CGSize(width: 150, height: 150)
    static let highPicture = CGSize(width: 200, height: 200)
    static let extremePicture = CGSize(width: 250, height: 250)
}

