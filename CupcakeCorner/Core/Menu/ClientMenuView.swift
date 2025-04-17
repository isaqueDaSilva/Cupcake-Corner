//
//  ClientMenu.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 4/16/25.
//

import SwiftUI

struct ClientMenuView: View {
    @State private var cupcakeRepository: CupcakeRepository
    
    var body: some View {
        NavigationStack {
            MenuView(cupcakeRepository: cupcakeRepository)
                .navigationDestination(for: Cupcake.self) { cupcake in
                    OrderView(cupcake: cupcake)
                }
        }
    }
    
    init(isPreview: Bool = false) {
        self._cupcakeRepository = .init(initialValue: .init(isPreview: isPreview))
    }
}

#Preview {
    ClientMenuView(isPreview: true)
}
