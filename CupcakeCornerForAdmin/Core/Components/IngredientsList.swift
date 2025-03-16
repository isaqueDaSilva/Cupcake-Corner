//
//  IngredientsList.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/10/25.
//


import SwiftUI

extension EditCupcake {
    struct IngredientsList: View {
        @Binding var ingredients: [String]
        
        var body: some View {
            VStack {
                Text("Ingredients:")
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                    .padding(.bottom, 5)
                
                ForEach(ingredients, id: \.self) { ingredient in
                    HStack {
                        IngredientCell(
                            for: ingredient,
                            isLastIngredient: ingredient == ingredients.last
                        )
                        
                        Button {
                            guard let index = ingredients.firstIndex(of: ingredient) else { return }
                            
                            return withAnimation {
                                ingredients.remove(at: index)
                            }
                        } label: {
                            Icon.trash.systemImage
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
        }
        
        init(ingredients: Binding<[String]>) {
            _ingredients = ingredients
        }
    }
}

#Preview {
    EditCupcake.IngredientsList(ingredients: .constant(["One", "Two"]))
        .padding()
}
