//
//  SignInView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//

import SwiftUI

struct SignInView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AccessHandler.self) private var accessHandler
    @FocusState var focusedField: FocusedField?
    
    @State private var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Text("Welcome Back!")
                    .font(.largeTitle)
                    .bold()
                    .frame(maxHeight: .infinity, alignment: .top)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                VStack {
                    LogoView(size: .midSizePicture)
                        .padding(.bottom, 20)
                    
                    self.fields
                    
                    ActionButton(
                        isLoading: self.$viewModel.isLoading,
                        width: .infinity
                    ) {
                        Text("Sign In")
                            .bold()
                    } action: {
                        loginAction()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    #if CLIENT
                    self.createAccountButton
                    #endif

                }
                .padding(.horizontal)
                .navigationTitle("Login")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(removing: .title)
                .appAlert(alert: $viewModel.error) { }
                .frame(maxHeight: .infinity)
            }
        }
    }
}

extension SignInView {
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
extension SignInView {
    @ViewBuilder
    private var createAccountButton: some View {
        NavigationLink {
            CreateAccountView()
        } label: {
            Text("Create an Account")
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
    }
}
#endif

extension SignInView {
    enum FocusedField: Hashable {
        case email
        case password
    }
}

extension SignInView {
    func loginAction() {
        if viewModel.email.isEmpty {
            focusedField = .email
        } else if viewModel.password.isEmpty {
            focusedField = .password
        } else {
            self.viewModel.signIn { response, privateKey, session in
                try self.accessHandler.fillStorange(
                    with: response,
                    privateKey: privateKey,
                    context: self.modelContext,
                    session: session
                )
            }
        }
    }
}

#Preview {
    SignInView()
        .environment(AccessHandler())
}
