//
//  ClientMenu.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 4/16/25.
//

import SwiftUI

struct ClientMenuView: View {
    @Environment(AccessHandler.self) private var accessHandler
    @State private var viewModel = MenuViewModel()
    
    var body: some View {
        NavigationStack {
            MenuView(viewModel: self.viewModel)
                .navigationDestination(for: ReadCupcake.self) { cupcake in
                    OrderRequestView(cupcake: cupcake)
                }
        }
    }
}

#Preview {
    ClientMenuView()
        .environment(AccessHandler())
}
