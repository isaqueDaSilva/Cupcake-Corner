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
                .navigationDestination(for: ReadCupcake.self) { cupcake in
                    OrderRequestView(cupcake: cupcake)
                }
        }
    }
}

#Preview {
    ClientMenuView()
}
