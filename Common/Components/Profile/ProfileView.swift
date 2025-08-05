//
//  ProfileView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//


import SwiftUI

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AccessHandler.self) private var accessHandler
    
    @State private var viewModel = ViewModel()
    
    private let colums: [GridItem] = [.init(.adaptive(minimum: 150))]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    InfoCell(
                        labelName: "Name",
                        text: self.accessHandler.userProfile?.name ?? "Deleted User"
                    )
                    
                    InfoCell(
                        labelName: "Email",
                        text: self.accessHandler.userProfile?.email ?? "Deleted User"
                    )
                    
                    self.historyNavigationView
                    
                    Grid {
                        GridRow {
                            ActionButton(
                                isLoading: self.$viewModel.isLoadingSignOutButton,
                                width: .infinity,
                                buttonStyle: .plain
                            ) {
                                HStack {
                                    Icon.rectangleAndArrow.systemImage
                                    
                                    Text("Sign Out")
                                        .font(.subheadline)
                                }
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity)
                            } action: {
                                self.viewModel.showAlert(for: .signOut)
                            }
                            .softBackground()
                            .disabled(viewModel.isDisabled)
                            
                            #if CLIENT
                            ActionButton(
                                isLoading: self.$viewModel.isLoadingDeleteAccountButton,
                                width: .infinity,
                                buttonStyle: .plain
                            ) {
                                HStack {
                                    Icon.trash.systemImage
                                    
                                    Text("Delete Account")
                                        .font(.subheadline)
                                }
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity)
                            } action: {
                                self.viewModel.showAlert(for: .deleteAccount)
                            }
                            .softBackground()
                            .disabled(viewModel.isDisabled)
                            #endif
                        }
                    }
                }
                .padding(.horizontal)
                .navigationTitle("Account")
                .appAlert(alert: $viewModel.alert) {
                    if viewModel.deletionType != nil {
                        Button("Cancel", role: .cancel) { }
                        
                        Button("OK", role: .destructive) {
                            self.viewModel.performRevocation(with: self.accessHandler.isPerfomingAction) {
                                revocationType, session in
                                try await self.accessHandler.revokeAccess(
                                    with: revocationType,
                                    context: self.modelContext,
                                    and: session
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

extension ProfileView {
    private var historyNavigationView: some View {
        NavigationLink {
            HistoryView(accessHandler: self.accessHandler)
        } label: {
            LabeledContent {
                Icon.chevronRight.systemImage
            } label: {
                Text("History")
            }
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .softBackground()
        }
        .buttonStyle(.plain)
    }
}

import SwiftData
#Preview {
    let userRepository = AccessHandler()
    
    return ProfileView()
        .environment(userRepository)
}
