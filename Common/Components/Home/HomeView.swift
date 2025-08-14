//
//  HomeView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import SwiftUI

struct HomeView: View {
    @Environment(AccessHandler.self) private var accessHandler
    @State private var tabSelected: TabSection = .menu
    
    var body: some View {
        Group {
            switch accessHandler.isPerfomingAction {
            case true:
                ProgressView()
            case false:
                switch self.accessHandler.userProfile {
                case .some(_):
                    self.tabView
                case .none:
                    SignInView()
                }
            }
        }
    }
}

extension HomeView {
    private var tabView: some View {
        TabView(selection: $tabSelected) {
            Tab(
                TabSection.menu.title,
                systemImage: TabSection.menu.iconName,
                value: .menu
            ) {
                #if CLIENT
                ClientMenuView()
                #elseif ADMIN
                AdminMenuView()
                #endif
            }
            
            Tab(
                TabSection.orders.title,
                systemImage: TabSection.orders.iconName,
                value: .orders
            ) {
                OrderView()
            }
            
            Tab(
                TabSection.profile.title,
                systemImage: TabSection.profile.iconName,
                value: .profile
            ) {
                ProfileView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}

#if DEBUG
#Preview {
    return HomeView()
        .environment(AccessHandler())
}
#endif
