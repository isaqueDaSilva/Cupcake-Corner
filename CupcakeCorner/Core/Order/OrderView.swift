//
//  OrderView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/10/25.
//

import ErrorWrapper
import SwiftUI

struct OrderView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var viewModel: ViewModel
    
    let cupcake: Cupcake
    
    var body: some View {
        ScrollView {
            VStack {
                cupcakeHighlight
                    .padding(.bottom)
                
                containerView
            }
            .padding([.horizontal, .bottom])
            .alert("Order Sent with Success",isPresented: $viewModel.isSuccessed) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Go to the bag and track the progress of your order in real time.")
            }
            .errorAlert(error: $viewModel.error) { }
            .sheet(isPresented: $viewModel.isShowingAboutCupcake) {
                AboutCupcakeView(
                    flavor: cupcake.flavor,
                    coverImageData: cupcake.coverImage,
                    madeWithText: self.madeWithText,
                    ingredientsText: self.ingredientsText,
                    dateDescriptionText: self.dateDescriptionText,
                    createAtText: self.createAtText
                )
            }
        }
    }
    
    init(cupcake: Cupcake) {
        self.cupcake = cupcake
        self._viewModel = .init(initialValue: .init(with: cupcake.price))
    }
}

extension OrderView {
    @ViewBuilder
    private var containerView: some View {
        Group {
            quantityChoice
                .padding(.bottom)
                .disabled(viewModel.isLoading)
            
            specialRequestChoices
                .padding(.bottom)
                .disabled(viewModel.isLoading)

            paymentMethodPicker
                .padding(.bottom)
                .disabled(viewModel.isLoading)
            
            orderTotalLabel
                .padding(.bottom, 10)
            
            ActionButton(
                isLoading: $viewModel.isLoading,
                label: "Make Order",
                width: .infinity,
                isDisabled: viewModel.isLoading
            ) {
                viewModel.makeOrder(cupcakeID: cupcake.id)
            }
        }
    }
}

extension OrderView {
    @ViewBuilder
    private var cupcakeHighlight: some View {
        VStack {
            HStack(alignment: .center) {
                Text(cupcake.flavor)
                    .headerSessionText(font: .title2)
                    .multilineTextAlignment(.center)
                
                Button {
                    viewModel.isShowingAboutCupcake = true
                } label: {
                    Icon.infoCircle.systemImage
                        .foregroundStyle(.blue)
                }
            }
            
            Image(by: cupcake.coverImage, with: .midHighPicture)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: 150, maxHeight: 150)
                .padding()
        }
        .frame(maxWidth: .infinity)
    }
}

extension OrderView {
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

extension OrderView {
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

extension OrderView {
    @ViewBuilder
    private var paymentMethodPicker: some View {
        VStack(alignment: .leading) {
            Text("Choice a payment method:")
                .headerSessionText(font: .title2)
            
            Grid {
                GridRow {
                    ForEach(PaymentMethod.allCases, id: \.id) { paymentMethod in
                        Text(paymentMethod.displayedName)
                            .font(.caption)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .selectionStyle {
                                viewModel.paymentMethod == paymentMethod ?
                                Color.blue : Color(uiColor: .systemGray3)
                            }
                            .onTapGesture {
                                viewModel.paymentMethod = paymentMethod
                            }
                            .animation(.default, value: viewModel.paymentMethod)
                    }
                }
            }
        }
    }
}

extension OrderView {
    @ViewBuilder
    private var specialRequestChoices: some View {
        VStack(alignment: .leading) {
            Text("Special Request")
                .headerSessionText(
                    font: .title2
                )
            
            VStack {
                SpecialRequest(
                    isActive: $viewModel.extraFrosting,
                    price: viewModel.extraFrostingPrice,
                    requestName: "Extra Frosting:"
                )
                .animation(.default, value: viewModel.extraFrostingPrice)
                .contentTransition(.numericText(value: Double(viewModel.extraFrostingPrice)))
                
                SpecialRequest(
                    isActive: $viewModel.addSprinkles,
                    price: viewModel.addSprinklesPrice,
                    requestName: "Extra Sprinkles:"
                )
                .animation(.default, value: viewModel.addSprinklesPrice)
                .contentTransition(.numericText(value: Double(viewModel.addSprinklesPrice)))
            }
            .font(.headline)
        }
    }
}

extension OrderView {
    @ViewBuilder
    private func SpecialRequest(
        isActive: Binding<Bool>,
        price: Double,
        requestName: String
    ) -> some View {
        SelectionPicker(isActive: isActive) {
            HStack {
                LabeledContent(
                    requestName,
                    value: price,
                    format: .currency(code: "USD")
                )
            }
            .contentShape(.rect)
        }
    }
}

extension OrderView {
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
        OrderView(cupcake: .init())
            .environment(UserRepository())
    }
}
