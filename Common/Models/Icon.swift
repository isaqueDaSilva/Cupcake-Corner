//
//  Icon.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import SwiftUI

enum Icon: String {
    case trash = "trash"
    case rectangleAndArrow = "rectangle.portrait.and.arrow.right"
    case bag = "bag"
    case shippingBox = "shippingbox"
    case person = "person"
    case chevronLeft = "chevron.left"
    case chevronRight = "chevron.right"
    case questionmarkDiamond = "questionmark.diamond"
    case plusCircle = "plus.circle"
    case plus = "plus"
    case truck = "truck.box"
    case magnifyingglass = "magnifyingglass"
    case pencil = "pencil"
    case exclamationmarkTriangleFill = "exclamationmark.triangle.fill"
    case menucard = "menucard"
    case photoOnRectangle = "photo.on.rectangle"
    case infoCircle = "info.circle"
    
    var systemImage: Image {
        Image(systemName: self.rawValue)
    }
    
    var uiSystemImage: UIImage? {
        .init(systemName: self.rawValue)
    }
}
