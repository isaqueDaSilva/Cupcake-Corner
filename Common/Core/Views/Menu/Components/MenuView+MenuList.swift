//
//  MenuList.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 4/16/25.
//

import SwiftUI

extension MenuView {
    struct MenuList: View {
        let cupcakeList: [Cupcake]
        
        private let colums: [GridItem] = [.init(.adaptive(minimum: 150))]
        
        var body: some View {
            ScrollView {
                LazyVGrid(columns: colums) {
                    ForEach(cupcakeList, id: \.id) { cupcake in
                        NavigationLink(value: cupcake) {
                            CupcakeCard(
                                flavor: cupcake.flavor,
                                coverImageData: cupcake.coverImage
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}
