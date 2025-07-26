//
//  MenuView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import SwiftUI

struct MenuView: View {
    @State private var isOpeningProfileView = false
    @Binding var viewModel: MenuViewModel
    
    @Namespace private var profileButtonNamespace
    private let profileButtonTransionID = "PROFILE_BUTTON_TRANSITION_ID"
    
    var body: some View {
        ZStack {
            if self.viewModel.isLoading && self.viewModel.isCupcakeListEmpty {
                OverlayEmptyView(
                    itemName: "Cupcakes",
                    isLoading: self.viewModel.isLoading,
                    isListEmpty: self.viewModel.cupcakes.isEmpty
                )
            }
            
            MenuListView(
                cupcakes: self.viewModel.cupcakes.values.elements,
                currentViewState: self.viewModel.viewState
            ) { isVisible, index in
                self.viewModel.fetchMorePages(
                    isVisible: isVisible,
                    index: index
                )
            }
        }
        .navigationTitle("Menu")
        .onAppear {
            self.viewModel.fetchPage()
        }
        .refreshable {
            self.viewModel.refresh()
        }
        .errorAlert(error: self.$viewModel.error) { }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    self.isOpeningProfileView = true
                } label: {
                    if #available(iOS 26, *) {
                        Icon.person.systemImage
                    } else {
                        Icon.personCircle.systemImage
                            .tint(.blue)
                    }
                }
                .matchedTransitionSource(
                    id: self.profileButtonTransionID,
                    in: self.profileButtonNamespace
                )
            }
            
            if #available(iOS 26, *) {
                ToolbarSpacer()
            }

        }
        .sheet(isPresented: $isOpeningProfileView) {
            UserAccountView()
                .environment(UserRepository())
                .navigationTransition(
                    .zoom(
                        sourceID: self.profileButtonTransionID,
                        in: self.profileButtonNamespace
                    )
                )
        }
    }
}

#Preview {
    NavigationStack {
        MenuView(viewModel: .constant(.init()))
    }
}

