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
        
        @State private var tabSelected: TabSection = .cupcakes
        
        var body: some View {
            TabView(selection: $tabSelected) {
                
                Tab(
                    TabSection.cupcakes.title,
                    systemImage: TabSection.cupcakes.iconName,
                    value: .cupcakes
                ) {
                    MenuView()
                }
                
                Tab(
                    TabSection.orders.title,
                    systemImage: TabSection.orders.iconName,
                    value: .orders
                ) {
                    BagView(userRepository: userRepository)
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

import SwiftData
#Preview {
    let inMemoryModelContext = ModelContext.inMemoryModelContext
    let userRepository = UserRepository()
    try? userRepository.load(with: inMemoryModelContext)
    
    return HomeView.HomeTabView().environment(userRepository)
}
