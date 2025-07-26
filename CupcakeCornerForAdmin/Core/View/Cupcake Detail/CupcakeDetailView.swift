//
//  CupcakeDetailView.swift
//  CupcakeCornerForAdmin
//
//  Created by Isaque da Silva on 3/10/25.
//

import SwiftUI

struct CupcakeDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = ViewModel()
    @State private var isUpdated: Action? = nil
    @Namespace private var plusButtonNamespace
    private let plusButtonID = "PLUS_BUTTON_TRANSITION"
    
    @State private var cupcake: ReadCupcake
    var action: (Action) -> Void
    
    var body: some View {
        ScrollView {
            VStack {
                AsyncCoverImageView(
                    imageName: cupcake.imageName,
                    size: .midSizePicture
                )
                .padding(.bottom, 10)
                
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
            .navigationBarBackButtonHidden()
            .toolbar {
                if #available(iOS 26, *) {
                    ToolbarItem(placement: .topBarTrailing) {
                        self.deleteButton
                            .tint(.red)
                    }
                    
                    ToolbarSpacer(.flexible, placement: .topBarTrailing)
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        self.editButton
                            .tint(.blue)
                    }
                } else {
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack {
                            self.deleteButton
                            self.editButton
                        }
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    BackButton {
                        if let isUpdated {
                            self.action(isUpdated)
                        } else {
                            self.action(.noAction)
                        }
                        
                        dismiss()
                    }
                }
            }
            .alert(
                "Delete Cupcake",
                isPresented: $viewModel.isShowingDeleteAlert
            ) {
                Button("Cancel", role: .cancel) { }
                
                Button("Delete", role: .destructive) {
                    viewModel.deleteCupcake(cupcake: self.cupcake) {
                        self.action(.delete(self.cupcake.id))
                    }
                }
            } message: {
                Text("Are you sure you want to delete this cupcake?")
            }
            .errorAlert(error: $viewModel.error) { }
            .sheet(isPresented: $viewModel.isShowingUpdateCupcakeView) {
                UpdateCupcakeView(cupcake: self.cupcake) { updatedCupcake in
                    if let updatedCupcake {
                        self.cupcake = updatedCupcake
                        self.isUpdated = .update(updatedCupcake)
                    }
                }
                .navigationTransition(
                    .zoom(
                        sourceID: self.plusButtonID,
                        in: self.plusButtonNamespace
                    )
                )
            }
        }
    }
    
    init(cupcake: ReadCupcake, action: @escaping (Action) -> Void) {
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

extension CupcakeDetailView {
    private var deleteButton: some View {
        Button(role: .destructive) {
            viewModel.isShowingDeleteAlert = true
        } label: {
            Icon.trash.systemImage
        }
        .disabled(viewModel.isLoading)
    }
    
    private var editButton: some View {
        Button {
            viewModel.isShowingUpdateCupcakeView = true
        } label: {
            Icon.pencil.systemImage
        }
        .disabled(viewModel.isLoading)
        .matchedTransitionSource(
            id: self.plusButtonID,
            in: self.plusButtonNamespace
        )
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        CupcakeDetailView(cupcake: .init()) { _ in }
    }
}
#endif
