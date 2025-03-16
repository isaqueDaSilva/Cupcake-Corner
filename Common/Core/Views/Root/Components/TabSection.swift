//
//  TabSection.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import SwiftUI

extension HomeView {
    enum TabSection: Hashable, CaseIterable {
        case cupcakes
        case orders
        case profile
    }
}

extension HomeView.TabSection: Identifiable {
    var id: String {
        switch self {
        case .cupcakes:
            "Cupcakes"
        case .orders:
            "Orders"
        case .profile:
            "Profile"
        }
    }
}

extension HomeView.TabSection {
    var title: String {
        return switch self {
        case .cupcakes:
            #if CLIENT
            "Buy"
            #elseif ADMIN
            "Cupcakes"
            #endif
        case .orders:
            #if CLIENT
            "Bag"
            #elseif ADMIN
            "Orders"
            #endif
        case .profile:
            "Profile"
        }
    }
}

extension HomeView.TabSection {
    var iconName: String {
        switch self {
        case .cupcakes:
            Icon.house.rawValue
        case .orders:
            Icon.bag.rawValue
        case .profile:
            Icon.person.rawValue
        }
    }
}
