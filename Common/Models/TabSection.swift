//
//  TabSection.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import SwiftUI

enum TabSection: Hashable, CaseIterable {
    case menu
    case orders
}

extension TabSection: Identifiable {
    var id: String {
        title
    }
}

extension TabSection {
    var title: String {
        return switch self {
        case .menu:
            "Menu"
        case .orders:
            "Orders"
        }
    }
}

extension TabSection {
    var iconName: String {
        switch self {
        case .menu:
            Icon.menucard.rawValue
        case .orders:
            Icon.bag.rawValue
        }
    }
}
