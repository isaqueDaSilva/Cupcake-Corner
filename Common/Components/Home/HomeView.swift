//
//  HomeView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import SwiftUI

struct HomeView: View {
    @Environment(UserRepository.self) private var userRepository
    @State private var tabSelected: TabSection = .menu
    
    var body: some View {
        Group {
            switch userRepository.user {
            case .some(_):
                self.tabView
                    .environment(userRepository)
            case .none:
                LoginView()
            }
        }
        .environment(userRepository)
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
                OrderView(userRepository: userRepository)
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
