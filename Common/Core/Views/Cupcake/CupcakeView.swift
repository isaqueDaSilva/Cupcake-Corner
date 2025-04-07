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
                            .containerRelativeFrame(.vertical)
                    case false:
                        switch viewModel.isCupcakeListEmpty {
                        case true:
                            EmptyStateView(
                                title: "No Cupcake Load",
                                description: "There are no cupcakes to be displayed.",
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
                    CreateNewCupcakeView { newCupcake in
                        viewModel.updateStorage(with: .create(newCupcake))
                    }
                }
                #endif
                .errorAlert(error: $viewModel.error) { }
                .navigationDestination(for: Cupcake.self) { cupcake in
                    
                    #if CLIENT
                    OrderView(cupcake: cupcake)
                    #elseif ADMIN
                    CupcakeDetailView(cupcake: cupcake) { action in
                        viewModel.updateStorage(with: action)
                    }
                    #endif
                }
                .environment(userRepository)
            }
            .refreshable {
                viewModel.fetch()
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
            cupcakeScrollList
        }
        .padding()
    }
}

extension CupcakeView {
    @ViewBuilder
    private func CupcakeCard(
        with flavor: String,
        and coverImageData: Data
    ) -> some View {
        GroupBox {
            ImageResizer(imageData: coverImageData, size: .midSizePicture) { image in
                image
                    .resizable()
                    .scaledToFit()
            }
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

#Preview {
    CupcakeView(isPreview: true)
        .environment(UserRepository())
}
