//
//  BalanceView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/14/25.
//

import Charts
import ErrorWrapper
import SwiftUI


struct BalanceView: View {
    @State private var viewModel: ViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                topLabel
                
                balanceChart
                
                chartLabel
                    .padding(.bottom, 10)
                
                Text("History")
                    .headerSessionText()
                    .padding(.bottom, 5)
                
                fullHistory
            }
            .padding(.horizontal)
            .navigationTitle("Balance")
            .toolbar {
                Button {
                    viewModel.isShowingSetFilter = true
                } label: {
                    Icon.magnifyingglass.systemImage
                }
            }
            .sheet(isPresented: $viewModel.isShowingSetFilter) {
                setFilter
                    .presentationDetents([.fraction(1/3)])
                    .presentationCornerRadius(10)
                    .errorAlert(error: $viewModel.error) { }
            }
        }
        .scrollDisabled(viewModel.flavors.isEmpty)
    }
    
    init(isPreview: Bool = false) {
        self._viewModel = .init(initialValue: .init(isPreview: isPreview))
    }
}

// MARK: - Balance Result Chart -
extension BalanceView {
    @ViewBuilder
    private var topLabel: some View {
        VStack {
            LabeledContent {
                Text(viewModel.balance?.totalOfPurchase ?? 0, format: .number)
            } label: {
                Text("Total of Purchase :")
                    .bold()
            }
            
            LabeledContent {
                Text("\(viewModel.initialDate, format: .dateTime.day().month().year()) -  \(viewModel.finalDate, format: .dateTime.day().month().year())")
            } label: {
                Text("Date Range:")
                    .bold()
            }
        }
        .padding(.bottom, 5)
    }
    
    @ViewBuilder
    private var balanceChart: some View {
        Chart {
            RuleMark(
                y: .value(
                    "Average",
                    viewModel.balance?.purchasingQuantityAverage ?? 0
                )
            )
            .foregroundStyle(.mint)
            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
            
            ForEach(viewModel.flavors, id: \.self) { flavor in
                BarMark(
                    x: .value(
                        "Cupcakes",
                        flavor
                    ),
                    y: .value(
                        "Sale numbers",
                        viewModel.balance?.purchaseValuePerFlavor[flavor] ?? 0
                    )
                )
                .foregroundStyle(highlightMostPurchaseFlavor(flavor).gradient)
                .cornerRadius(5)
                .annotation(position: .top, alignment: .center) {
                    Text(viewModel.balance?.purchaseValuePerFlavor[flavor] ?? 0, format: .number)
                        .font(.caption)
                        .bold()
                }
            }
        }
    }
    
    @ViewBuilder
    private var chartLabel: some View {
        HStack {
            HStack {
                Icon.lineDiagonal.systemImage
                    .rotationEffect(Angle(degrees: 45))
                    .foregroundColor(.mint)
                
                Text("Avarge: \(viewModel.balance?.purchasingQuantityAverage ?? 0)")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 0) {
                Group {
                    #if CLIENT
                    Text("Total Spent:")
                    #elseif ADMIN
                    Text("Billing:")
                    #endif
                }
                .padding(.trailing, 5)
                
                Text(viewModel.balance?.totalSpent ?? 0, format: .currency(code: "USD"))
            }
        }
        .headerSessionText(
            font: .caption2,
            color: .secondary
        )
    }
}

extension BalanceView {
    private func highlightMostPurchaseFlavor(_ currentFlavor: String) -> Color {
        viewModel.balance?.mostPurchaseFlavor == currentFlavor ? .pink : .pink.opacity(0.6)
    }
}

// MARK: - History -

extension BalanceView {
    @ViewBuilder
    private var fullHistory: some View {
        if viewModel.flavors.isEmpty {
            OrderEmptyView()
        } else {
            ForEach(viewModel.flavors, id: \.self) { flavor in
                Text(flavor)
                    .headerSessionText(font: .headline)
                
                ForEach(viewModel.balance?.fullHistory[flavor] ?? [], id: \.id) { order in
                    
                    ItemCard(
                        name: order.title,
                        description: order.description,
                        price: order.finalPrice
                    )
                }
            }
        }
    }
}

// MARK: - Set Filter -
extension BalanceView {
    @ViewBuilder
    private var setFilter: some View {
        NavigationStack {
            VStack {
                
                fromDatePicker
                
                Divider()
                
                toDatePicker
                
                Divider()
                    .padding(.bottom, 10)
                
                setFilterActionButton
            }
            .padding(.horizontal)
            .navigationTitle("Set Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button("Done") {
                    viewModel.isShowingSetFilter = false
                }
            }
        }
    }
    
    @ViewBuilder
    private var fromDatePicker: some View {
        DatePicker(
            "From:",
            selection: $viewModel.initialDate,
            in: ...viewModel.finalDate.addingTimeInterval(-.oneDay),
            displayedComponents: .date
        )
        .bold()
    }
    
    
    @ViewBuilder
    private var toDatePicker: some View {
        DatePicker(
            "To:",
            selection: $viewModel.finalDate,
            in: ...Date(),
            displayedComponents: .date
        )
        .bold()
    }
    
    @ViewBuilder
    var setFilterActionButton: some View {
        ActionButton(
            isLoading: $viewModel.isLoading,
            label: "Set Filter",
            width: .infinity,
            isDisabled: viewModel.isLoading
        ) {
            viewModel.getBalance()
        }
    }
}

#Preview {
    NavigationStack {
        BalanceView(isPreview: true)
    }
}
