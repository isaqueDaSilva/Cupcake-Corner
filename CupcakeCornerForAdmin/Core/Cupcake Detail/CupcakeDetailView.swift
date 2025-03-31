//
//  CupcakeDetailView.swift
//  CupcakeCornerForAdmin
//
//  Created by Isaque da Silva on 3/10/25.
//

import ErrorWrapper
import SwiftUI

struct CupcakeDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = ViewModel()
    
    @State private var cupcake: Cupcake
    var action: (Action) -> Void
    
    var body: some View {
        ScrollView {
            VStack {
                CoverImageView(
                    imageData: cupcake.coverImage,
                    size: .midHighPicture
                )
                
                Text("Cupcake Information:")
                    .headerSessionText(
                        font: .headline,
                        color: .secondary
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                LabeledDescription(
                    with: "Flavor",
                    and: "\(cupcake.flavor)"
                )
                
                LabeledDescription(
                    with: "Price",
                    and: "\(cupcake.price, format: .currency(code: "USD"))"
                )
                .padding(.bottom)
                
                Text("Ingredients:")
                    .headerSessionText(
                        font: .headline,
                        color: .secondary
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                    .padding(.bottom, 5)
                
                ForEach(cupcake.ingredients, id: \.self) { ingredient in
                    IngredientCell(
                        for: ingredient,
                        isLastIngredient: ingredient == cupcake.ingredients.last
                    )
                }
            }
            .padding()
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(role: .destructive) {
                    viewModel.isShowingDeleteAlert = true
                } label: {
                    Icon.trash.systemImage
                }
                .disabled(viewModel.isLoading)
                
                Button {
                    viewModel.isShowingUpdateCupcakeView = true
                } label: {
                    Icon.pencil.systemImage
                }
                .disabled(viewModel.isLoading)
            }
            .alert(
                "Delete Cupcake",
                isPresented: $viewModel.isShowingDeleteAlert
            ) {
                Button("Cancel", role: .cancel) { }
                
                Button("Delete", role: .destructive) {
                    viewModel.deleteCupcake(with: cupcake.id) { cupcakeID in
                        action(.delete(cupcakeID))
                        dismiss()
                    }
                }
            } message: {
                Text("Are you sure you want to delete this cupcake?")
            }
            .errorAlert(error: $viewModel.error) { }
            .sheet(isPresented: $viewModel.isShowingUpdateCupcakeView) {
                UpdateCupcakeView(cupcake: self.cupcake) { updatedCupcake in
                    self.cupcake = updatedCupcake
                    action(.update(updatedCupcake))
                }
            }
        }
    }
    
    init(cupcake: Cupcake, action: @escaping (Action) -> Void) {
        self._cupcake = .init(initialValue: cupcake)
        self.action = action
    }
}

extension CupcakeDetailView {
    @ViewBuilder
    func LabeledDescription(
        with title: String,
        and description: LocalizedStringKey
    ) -> some View {
        LabeledContent{
            Text(description)
        } label: {
            Text(title)
        }
        .softBackground()
    }
}


#if DEBUG
#Preview {
    NavigationStack {
        CupcakeDetailView(cupcake: .init()) { _ in }
    }
}
#endif
