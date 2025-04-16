//
//  ClientMenu.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 4/16/25.
//

import SwiftUI

struct ClientMenu: View {
    var body: some View {
        MenuView()
            .navigationDestination(for: Cupcake.self) { cupcake in
                OrderView(cupcake: cupcake)
            }
    }
}

#Preview {
    ClientMenu()
}
