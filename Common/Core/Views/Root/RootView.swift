//
//  RootView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import SwiftUI

struct HomeView: View {
    @Environment(UserRepository.self) private var userRepository
    
    @State private var tabSelected: TabSection = .cupcakes
    
    var body: some View {
        Group {
            switch userRepository.user {
            case .some(_):
                tabs
            case .none:
                LoginView()
            }
        }
        .environment(userRepository)
    }
}

extension HomeView {
    @ViewBuilder
    private var tabs: some View {
        TabView(selection: $tabSelected) {
            
            Tab(
                TabSection.cupcakes.title,
                systemImage: TabSection.cupcakes.iconName,
                value: .cupcakes
            ) {
                CupcakeView()
            }
            
            Tab(
                TabSection.orders.title,
                systemImage: TabSection.orders.iconName,
                value: .orders
            ) {
                BagView()
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

#if DEBUG
import SwiftData
#Preview {
    let inMemoryModelContext = ModelContext.inMemoryModelContext
    let userRepository = UserRepository()
    try? userRepository.load(with: inMemoryModelContext)
    
    return HomeView()
        .environment(userRepository)
}
#endif
