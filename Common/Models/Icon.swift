//
//  Icon.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import SwiftUI

enum Icon: String {
    case house = "house"
    case trash = "trash"
    case rectangleAndArrow = "rectangle.portrait.and.arrow.right"
    case bag = "bag"
    case shippingBox = "shippingbox"
    case person = "person"
    case personSlash = "person.slash"
    case personCircle = "person.circle"
    case bookmark = "bookmark"
    case bookmarkFill = "bookmark.fill"
    case chevronLeft = "chevron.left"
    case chevronRight = "chevron.right"
    case chevronDown = "chevron.down"
    case questionmarkDiamond = "questionmark.diamond"
    case plusCircle = "plus.circle"
    case plus = "plus"
    case squareSlash = "square.slash"
    case truck = "truck.box"
    case magnifyingglass = "magnifyingglass"
    case arrowClockwise = "arrow.clockwise"
    case pencil = "pencil"
    case infoCircle = "info.circle"
    case exclamationmarkTriangleFill = "exclamationmark.triangle.fill"
    case lineDiagonal = "line.diagonal"
    case menucard = "menucard"
    case nosign = "nosign"
    case photoOnRectangle = "photo.on.rectangle"
    
    var systemImage: Image {
        Image(systemName: self.rawValue)
    }
    
    var uiSystemImage: UIImage? {
        .init(systemName: self.rawValue)
    }
}
