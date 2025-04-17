//
//  HomeTabView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 4/16/25.
//

import SwiftUI

extension HomeView {
    struct HomeTabView: View {
        @Environment(UserRepository.self) private var userRepository
        
        @State private var tabSelected: TabSection = .menu
        
        var body: some View {
            TabView(selection: $tabSelected) {
                
                Tab(
                    TabSection.menu.title,
                    systemImage: TabSection.menu.iconName,
                    value: .menu
                ) {
                    menuView
                }
                
                Tab(
                    TabSection.orders.title,
                    systemImage: TabSection.orders.iconName,
                    value: .orders
                ) {
                    OrderView(userRepository: userRepository)
                }
                
                Tab(
                    TabSection.profile.title,
                    systemImage: TabSection.profile.iconName,
                    value: .profile
                ) {
                    UserAccountView()
                }
            }
            .tabViewStyle(.sidebarAdaptable)
        }
    }
}


extension HomeView.HomeTabView {
    @ViewBuilder
    private var menuView: some View {
        #if CLIENT
        ClientMenuView()
        #elseif ADMIN
        AdminMenuView()
        #endif
    }
}
import SwiftData
#Preview {
    let inMemoryModelContext = ModelContext.inMemoryModelContext
    let userRepository = UserRepository()
    try? userRepository.load(with: inMemoryModelContext)
    
    return HomeView.HomeTabView().environment(userRepository)
}
