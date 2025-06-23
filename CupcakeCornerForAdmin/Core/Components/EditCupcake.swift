//
//  EditCupcake.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/10/25.
//

import SwiftUI
import PhotosUI

struct EditCupcake: View {
    @Binding var pickerItemSelected: PhotosPickerItem?
    @Binding var flavorName: String
    @Binding var price: Double
    @Binding var ingredients: [String]
    @Binding var isLoading: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var focusedField: FocusedField?
    
    @State private var ingredientName = ""
    
    let navigationTitle: String
    let coverImageData: Data?
    
    var action: (@escaping () -> Void) -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    CoverImageView(
                        imageData: coverImageData,
                        size: .midHighPicture
                    )
                    
                    PhotosPicker(
                        "Select an Cover",
                        selection: $pickerItemSelected
                    )
                    .buttonStyle(BorderedProminentButtonStyle())
                    .padding(.bottom)
                    
                    
                    Text("Cupcake Information:")
                        .headerSessionText(
                            font: .headline,
                            color: .secondary
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    fields
                        .padding(.bottom)
                    
                    if !ingredients.isEmpty {
                        IngredientsList(ingredients: $ingredients)
                    }
                    
                    
                }
                .padding()
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Icon.chevronLeft.systemImage
                            Text("Back")
                        }
                    }

                }
                
                ToolbarItem(placement: .confirmationAction) {
                    ActionButton(
                        isLoading: $isLoading,
                        label: "OK"
                    ) {
                        if flavorName.isEmpty {
                            focusedField = .flavorName
                        } else if price < 1 {
                            focusedField = .price
                        } else if ingredients.isEmpty {
                            focusedField = .ingredients
                        } else {
                            action {
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
    }
}

extension EditCupcake {
    enum FocusedField: Hashable {
        case flavorName
        case price
        case ingredients
    }
}

extension EditCupcake {
    @ViewBuilder
    private var insertFlavorField: some View {
        TextFieldFocused(
            focusedField: $focusedField,
            focusedFieldValue: .flavorName,
            fieldType: .textField(
                "Insert flavor name here...",
                $flavorName
            ),
            inputAutocapitalization: .sentences
        )
    }
}

extension EditCupcake {
    @ViewBuilder
    private var priceField: some View {
        TextFieldFocused(
            focusedField: $focusedField,
            focusedFieldValue: .price,
            fieldType: .textField("Insert the price here...", Binding {
                price.toCurreny
            } set: { priceString in
                self.price = NSString(
                    string: "\(priceString.dropFirst(4))"
                ).doubleValue
            }),
            keyboardType: .decimalPad,
            inputAutocapitalization: .sentences
        )
    }
}

extension EditCupcake {
    private func addIngredient() {
        withAnimation {
            guard !ingredientName.isEmpty else { return }
            ingredients.append(ingredientName)
            ingredientName = ""
        }
    }
    
    @ViewBuilder
    private var ingredientsField: some View {
        HStack {
            TextFieldFocused(
                focusedField: $focusedField,
                focusedFieldValue: .ingredients,
                fieldType: .textField(
                    "Insert a new Ingredient here...",
                    $ingredientName
                ),
                inputAutocapitalization: .sentences
            )
            
            Button{
                addIngredient()
            } label: {
                Icon.plusCircle.systemImage
            }
            .buttonStyle(.plain)
            .padding(.trailing, 5)
        }
    }
}

extension EditCupcake {
    @ViewBuilder
    private var fields: some View {
        VStack(spacing: 10) {
            insertFlavorField
            
            priceField
            
            ingredientsField
                .onSubmit(of: .text) {
                    addIngredient()
                }
        }
    }
}

#Preview {
    EditCupcake(
        pickerItemSelected: .constant(nil),
        flavorName: .constant(""),
        price: .constant(0),
        ingredients: .constant(["One", "Two"]),
        isLoading: .constant(false),
        navigationTitle: "Create",
        coverImageData: nil
    ) { _ in }
}
