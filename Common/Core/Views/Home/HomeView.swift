//
//  HomeView.swift
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
                HomeTabView()
                    .environment(userRepository)
            case .none:
                LoginView()
            }
        }
        .environment(userRepository)
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
