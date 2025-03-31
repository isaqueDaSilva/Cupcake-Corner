//
//  CreateAccountView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//

import ErrorWrapper
import SwiftUI

struct CreateAccountView: View {
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = ViewModel()
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                LogoView(size: .midSizePicture)
                    .padding(proxy.frame(in: .global).maxY * 0.07)
                
                EditAccount(
                    name: $viewModel.newUser.name,
                    email: $viewModel.newUser.email,
                    password: $viewModel.newUser.password,
                    confirmPassword: $viewModel.newUser.confirmPassword,
                    isLoading: $viewModel.isLoading,
                    buttonLabel: "Create"
                ) {
                    viewModel.createAccount()
                }
                .navigationTitle("Create Account")
                .navigationBarTitleDisplayMode(.inline)
                .errorAlert(error: $viewModel.error) { }
                .alert(
                    "Account Created",
                    isPresented: $viewModel.isShowingCreateAccountConfirmation
                ) {
                    Button("OK") {
                        dismiss()
                    }
                } message: {
                    Text("Your account was created with success, click in OK and log in the system for gets the full access in the App.")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CreateAccountView()
    }
}
