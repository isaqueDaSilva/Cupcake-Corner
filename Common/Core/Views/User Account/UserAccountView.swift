//
//  UserAccountView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//

import ErrorWrapper
import SwiftUI

struct UserAccountView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(UserRepository.self) private var userRepository
    
    @State private var viewModel = ViewModel()
    
    private let colums: [GridItem] = [.init(.adaptive(minimum: 150))]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    userInfo
                    
                    balanceNavigationButton
                    
                    Grid {
                        GridRow {
                            signOutButton
                            
                            #if CLIENT
                            deleteAccountButton
                            #endif
                        }
                    }
                }
                .padding(.horizontal)
                .navigationTitle("Account")
                .alert(viewModel.alertTitle, isPresented: $viewModel.isShowingAlert) {
                    Button("Cancel", role: .cancel) { }
                    
                    Button("OK", role: .destructive) {
                        viewModel.deletionAction {
                            try userRepository.delete(with: modelContext)
                        }
                    }
                } message: {
                    Text(viewModel.alertMessage)
                }
                .errorAlert(error: $viewModel.error) { }
            }
        }
    }
}

extension UserAccountView {
    @ViewBuilder
    private var userInfo: some View {
        LabeledContent {
            Text(userRepository.user?.name ?? "No User Saved")
        } label: {
            Text("Name:")
        }
        .bold()
        .frame(maxWidth: .infinity, alignment: .leading)
        .softBackground()
    }
}

extension UserAccountView {
    @ViewBuilder
    private var balanceNavigationButton: some View {
        NavigationLink {
            BalanceView()
        } label: {
            HStack {
                Text("Balance")
                    .bold()
                
                Icon.chevronRight.systemImage
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .softBackground()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension UserAccountView {
    @ViewBuilder
    private var signOutButton: some View {
        Button(role: .destructive) {
            viewModel.showAlert(for: .signOut)
        } label: {
            HStack {
                Icon.rectangleAndArrow.systemImage
                
                Text("Sign Out")
                    .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .softBackground()
        .disabled(viewModel.isDisabled)
    }
    
    #if CLIENT
    @ViewBuilder
    private var deleteAccountButton: some View {
        Button(role: .destructive) {
            viewModel.showAlert(for: .deleteAccount)
        } label: {
            HStack {
                Icon.trash.systemImage
                
                Text("Delete Account")
                    .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .softBackground()
        .disabled(viewModel.isDisabled)
    }
    #endif
}

import SwiftData
#Preview {
    let inMemoryModelContext = ModelContext.inMemoryModelContext
    let userRepository = UserRepository()
    try? userRepository.load(with: inMemoryModelContext)
    
    return UserAccountView()
        .environment(userRepository)
}
