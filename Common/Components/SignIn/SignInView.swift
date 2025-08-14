//
//  SignInView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//

import SwiftUI

struct SignInView: View {
    @Environment(\.colorScheme) private var colorScheme
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

                }
            }
            .padding(.horizontal)
            .navigationTitle("Login")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(removing: .title)
            .appAlert(alert: $viewModel.error) { }
            #if CLIENT
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    self.createAccountButton
                }
            }
            #endif
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
        HStack(spacing: 0) {
            Text("Dont have an account?")
                .foregroundStyle(self.colorScheme == .light ? .black : .white)
                .bold()
            
            NavigationLink {
                CreateAccountView()
            } label: {
                Text("Create one")
                    .underline()
                    .foregroundStyle(.blue)
            }
        }
        .frame(maxWidth: .infinity)
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
            self.focusedField = .email
        } else if viewModel.password.isEmpty {
            self.focusedField = .password
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
