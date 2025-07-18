//
//  ClientMenu.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 4/16/25.
//

import SwiftUI

struct ClientMenuView: View {
    @State private var viewModel = MenuViewModel()
    
    var body: some View {
        NavigationStack {
            MenuView(viewModel: $viewModel)
                .navigationDestination(for: NavigationInfo.self) { info in
                    OrderRequestView(cupcake: info.cupcake)
                }
        }
    }
}

#Preview {
    ClientMenuView()
}
