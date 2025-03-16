//
//  CupcakeView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import ErrorWrapper
import SwiftUI

struct CupcakeView: View {
    @Environment(UserRepository.self) private var userRepository
    @State private var viewModel: ViewModel
    private let colums: [GridItem] = [.init(.adaptive(minimum: 150))]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Group {
                    switch viewModel.isLoading {
                    case true:
                        ProgressView()
                    case false:
                        switch viewModel.isCupcakeListEmpty {
                        case true:
                            EmptyStateView(
                                title: "No Cupcake Load",
                                description: emptyStateDescription,
                                icon: .magnifyingglass
                            )
                            .containerRelativeFrame(.vertical)
                        case false:
                            cupcakeViewLoad
                        }
                    }
                }
                .navigationTitle("Cupcakes")
                #if ADMIN
                .toolbar {
                    Button {
                        viewModel.isShowingCreateNewCupcake = true
                    } label: {
                        Icon.plusCircle.systemImage
                    }
                    #if !DEBUG
                    .disabled(userRepository.user == nil)
                    #endif
                }
                .sheet(isPresented: $viewModel.isShowingCreateNewCupcake) {
                    CreateNewCupcake { newCupcake in
                        viewModel.cupcakesDictionary.updateValue(
                            newCupcake,
                            forKey: newCupcake.id
                        )
                    }
                }
                #endif
                .errorAlert(error: $viewModel.error) { }
                .navigationDestination(for: Cupcake.self) { cupcake in
                    
                    #if CLIENT
                    OrderView(
                        cupcake: cupcake,
                        isCupcakeNew: cupcake == viewModel.newestCupcake
                    )
                    #elseif ADMIN
                    CupcakeDetailView(cupcake: cupcake) { action in
                        switch action {
                        case .update(let updatedCupcake):
                            viewModel
                                .cupcakesDictionary[updatedCupcake.id] = updatedCupcake
                        case .delete(let cupcakeID):
                            viewModel.cupcakesDictionary.removeValue(forKey: cupcakeID)
                        }
                    }
                    #endif
                }
                .environment(userRepository)
            }
            .refreshable {
                viewModel.fetchCupcakes()
            }
        }
    }
    
    init(isPreview: Bool = false) {
        self._viewModel = .init(initialValue: .init(isPreview: isPreview))
    }
}

// MARK: - Main View -
extension CupcakeView {
    @ViewBuilder
    private var cupcakeViewLoad: some View {
        VStack {
            #if CLIENT
            newestCupcakeHighlights
            
            if !viewModel.cupcakes.isEmpty {
                Text("Cupcakes")
                    .headerSessionText()
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
            }
            #endif
            
            cupcakeScrollList
        }
        .padding()
    }
}

// MARK: - Highlighted Cupcake -
#if CLIENT
extension CupcakeView {
    @ViewBuilder
    private var newestCupcakeHighlights: some View {
        VStack {
            if let newstCupcake = viewModel.newestCupcake {
                Text("New")
                    .headerSessionText()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                cupcakeHighlight(newstCupcake)
            }
        }
        .padding(.bottom)
    }
    
    @ViewBuilder
    private func cupcakeCoverImage(_ imageData: Data) -> some View {
        Image(
            by: imageData,
            with: .init(
                width: 250,
                height: 250
            )
        )
        .resizable()
        .scaledToFit()
        .padding(.bottom)
        .frame(alignment: .leading)
    }
    
    @ViewBuilder
    private func priceView(_ price: Double) -> some View {
        Text(
            "From \(price, format: .currency(code: "USD"))"
        )
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private func headerView(flavor: String, ingredients: [String]) -> some View {
        VStack(alignment: .leading) {
            Text(flavor)
            
            Text("Made with \(ingredients.joined(separator: ", "))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder
    private var buyButtonLabel: some View {
        Text("Buy")
            .foregroundStyle(.blue)
            .padding([.top, .bottom], 2)
            .padding(.horizontal, 10)
            .background(
                Capsule()
                    .fill(.gray.opacity(0.25))
            )
    }
    
    @ViewBuilder
    private func cupcakeHighlight(_ newestCupcake: Cupcake) -> some View {
        VStack {
            
            GroupBox {
                VStack(alignment: .leading) {
                    cupcakeCoverImage(newestCupcake.coverImage)
                    
                    HStack {
                        priceView(newestCupcake.price)
                        
                        NavigationLink(value: newestCupcake) {
                            buyButtonLabel
                        }
                        .buttonStyle(.plain)
                    }
                }
                
            } label: {
                headerView(
                    flavor: newestCupcake.flavor,
                    ingredients: newestCupcake.ingredients
                )
            }
        }
    }
}
#endif

extension CupcakeView {
    @ViewBuilder
    private func CupcakeCard(
        with flavor: String,
        and coverImageData: Data
    ) -> some View {
        GroupBox {
            Image(by: coverImageData, with: .midSizePicture)
                .resizable()
                .scaledToFit()
        } label: {
            Text(flavor)
                .lineLimit(1)
        }
    }
}

extension CupcakeView {
    @ViewBuilder
    private var cupcakeScrollList: some View {
        LazyVGrid(columns: colums) {
            ForEach(
                viewModel.cupcakes,
                id: \.id
            ) { cupcake in
                NavigationLink(value: cupcake) {
                    CupcakeCard(
                        with: cupcake.flavor,
                        and: cupcake.coverImage
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}


// MARK: - Helper Text -
extension CupcakeView {
    private var emptyStateDescription: String {
        #if CLIENT
        return "It looks like there are no cupcakes on the menu to display, please refresh the page or come back later to check out more."
        #elseif ADMIN
        return "There are no cupcakes to be displayed. This may be because you are not logged in to your account or there are no cupcakes created."
        #endif
    }
}

#Preview {
    CupcakeView(isPreview: true)
        .environment(UserRepository())
}
