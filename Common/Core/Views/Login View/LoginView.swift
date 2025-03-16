//
//  LoginView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//

import ErrorWrapper
import SwiftUI

struct LoginView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(UserRepository.self) private var userRepository
    @FocusState var focusedField: FocusedField?
    
    @State private var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                VStack {
                    LogoView()
                        .padding(.bottom, 20)
                    
                    fields
                        .padding(.bottom, 5)
                    
                    ActionButton(
                        isLoading: $viewModel.isLoading,
                        label: "Sign In",
                        width: .infinity
                    ) {
                        loginAction()
                    }
                }
                .padding(.horizontal)
                .position(
                    x: proxy.frame(in: .local).midX,
                    y: proxy.frame(in: .local).midY - 50
                )
                .navigationTitle("Login")
                #if CLIENT
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        createAccountButton
                    }
                }
                #endif
                .errorAlert(error: $viewModel.error) { }
            }
        }
    }
}

extension LoginView {
    @ViewBuilder
    private var fields: some View {
        VStack {
            TextFieldFocused(
                focusedField: $focusedField,
                focusedFieldValue: .email,
                fieldType: .textField(
                    "Insert your email here...",
                    $viewModel.email
                ),
                keyboardType: .emailAddress,
                isAutocorrectionDisabled: true
            )
            
            TextFieldFocused(
                focusedField: $focusedField,
                focusedFieldValue: .password,
                fieldType: .secureField(
                    "Insert your password here...",
                    $viewModel.password
                ),
                isAutocorrectionDisabled: true
            )
        }
    }
}

#if CLIENT
extension LoginView {
    @ViewBuilder
    private var createAccountButton: some View {
        HStack {
            Text("No Account?")
                .bold()
            
            NavigationLink {
                CreateAccountView()
            } label: {
                Text("Create an Account")
                    .foregroundStyle(.blue)
                    .underline()
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
#endif

extension LoginView {
    enum FocusedField: Hashable {
        case email
        case password
    }
}

extension LoginView {
    func loginAction() {
        if viewModel.email.isEmpty {
            focusedField = .email
        } else if viewModel.password.isEmpty {
            focusedField = .password
        } else {
            viewModel.performLogin { newUser in
                try userRepository.insert(newUser, with: modelContext)
            }
        }
    }
}

#Preview {
    LoginView()
        .environment(UserRepository())
}
