//
//  OrderRequestView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/10/25.
//

import SwiftUI

struct OrderRequestView: View {
    @Bindable private var accessHandler: AccessHandler
    @Environment(\.dismiss) var dismiss
    
    @State private var viewModel: ViewModel
    
    let cupcake: ReadCupcake
    
    var body: some View {
        ScrollView {
            VStack {
                AsyncCoverImageView(
                    imageName: cupcake.imageName,
                    size: .midHighPicture,
                    accessHandler: self.accessHandler
                )
                .padding(.bottom)
                
                aboutCupcake
                    .padding(.bottom)
                
                quantityChoice
                    .padding(.bottom)
                
                orderTotalLabel
                    .padding(.bottom)
                
                ActionButton(isLoading: self.$viewModel.isLoading, width: .infinity) {
                    Text("Order")
                } action: {
                    self.viewModel.makeOrder(
                        with: self.cupcake.id,
                        isPerfomingAction: self.accessHandler.isPerfomingAction
                    )
                }
            }
            .padding([.horizontal, .bottom])
            .appAlert(alert: $viewModel.alert) {
                if viewModel.isSuccessed {
                    Button("OK") {
                        dismiss()
                    }
                }
            }
            .onChange(of: accessHandler.isPerfomingAction) { oldValue, newValue in
                guard newValue, newValue != oldValue && !self.viewModel.executionScheduler.isEmpty else { return }
                
                self.viewModel.executionScheduler[0]()
            }
        }
        .navigationTitle(cupcake.flavor)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarVisibility(.hidden, for: .tabBar)
    }
    
    init(accessHandler: AccessHandler,cupcake: ReadCupcake) {
        self.cupcake = cupcake
        self._viewModel = .init(initialValue: .init(with: cupcake.price))
        self._accessHandler = .init(accessHandler)
    }
}

extension OrderRequestView {
    private var aboutCupcake: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Icon.infoCircle.systemImage
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.blue)
                Text("About the Cupcake")
                    .headerSessionText(font: .title2)
            }
            .padding(.bottom, 5)
            
            LabeledContent {
                Text(ingredientsText)
            } label: {
                Text(madeWithText)
            }
            
            LabeledContent {
                Text(dateDescriptionText)
            } label: {
                Text(createAtText)
            }

        }
    }
}

extension OrderRequestView {
    @ViewBuilder
    private var orderTotalLabel: some View {
        LabeledContent {
            Text(viewModel.finalPrice, format: .currency(code: "USD"))
                .animation(.default, value: viewModel.finalPrice)
                .contentTransition(.numericText(value: Double(viewModel.finalPrice)))
        } label: {
            Text("Total:")
                .bold()
        }
        .font(.headline)
    }
}

extension OrderRequestView {
    @ViewBuilder
    private var quantityChoice: some View {
        VStack(alignment: .leading) {
            Text("How much cakes do you want?")
                .headerSessionText(font: .title2)
            
            HStack {
                
                Stepper(
                    "Number of Cakes: \(viewModel.quantity)",
                    value: $viewModel.quantity,
                    in: 1...20
                )
                .animation(.default, value: viewModel.quantity)
                .contentTransition(.numericText(value: Double(viewModel.quantity)))
                .font(.headline)
            }
        }
    }
}

extension OrderRequestView {
    private var madeWithText: AttributedString {
        var message = AttributedString("Made with: ")
        message.font = .headline
        _ = message.font?.weight(.bold)
        
        return message
    }
    
    private var ingredientsText: AttributedString {
        let cupcakeIngredients = cupcake.ingredients
        var ingredients = AttributedString(cupcakeIngredients.joined(separator: ", "))
        ingredients.font = .headline
        _ = ingredients.font?.weight(.medium)
        ingredients.foregroundColor = .secondary
        
        return ingredients
    }
    
    private var createAtText: AttributedString {
        var message = AttributedString("Create At: ")
        message.font = .headline
        _ = message.font?.weight(.bold)
        
        return message
    }
    
    private var dateDescriptionText: AttributedString {
        let cupcakeCreateAt = cupcake.createdAt
        var dateDescription = AttributedString(cupcakeCreateAt?.dateString(isDisplayingTime: false) ?? "N/A")
        dateDescription.font = .headline
        _ = dateDescription.font?.weight(.medium)
        dateDescription.foregroundColor = .secondary
        
        return dateDescription
    }
}

#Preview {
    NavigationStack {
        OrderRequestView(accessHandler: .init(), cupcake: .init())
            .environment(AccessHandler())
    }
}
