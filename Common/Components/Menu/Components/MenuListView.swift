//
//  MenuListView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 7/26/25.
//

import SwiftUI

struct MenuListView: View {
    let cupcakes: [ReadCupcake]
    let currentViewState: ViewState
    var fetchMoreAction: (Bool, Int) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(self.cupcakes.indices, id: \.self) { index in
                    if !self.cupcakes.isEmpty {
                        NavigationLink(value: self.cupcakes[index]) {
                            ItemCard(
                                imageName: self.cupcakes[index].imageName,
                                name: self.cupcakes[index].flavor,
                                description: self.cupcakes[index].description,
                                price: self.cupcakes[index].price
                            )
                        }
                        .buttonStyle(.plain)
                        .onScrollVisibilityChange(threshold: 0.8) { isVisible in
                            self.fetchMoreAction(isVisible, index)
                        }
                    }
                }
                
                Spinner(currentViewState: self.currentViewState)
            }
            .padding()
        }
    }
}

#Preview {
    MenuListView(
        cupcakes: ReadCupcake.mocks.values.elements,
        currentViewState: .default
    ) { _,_ in }
}
