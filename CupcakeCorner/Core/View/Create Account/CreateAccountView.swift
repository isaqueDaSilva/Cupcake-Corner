//
//  CreateAccountView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//

import SwiftData
import SwiftUI

struct CreateAccountView: View {
    @Environment(AccessHandler.self) private var accessHandler
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = ViewModel()
    
    var body: some View {
        GeometryReader { proxy in
            VStack {
                LogoView(size: .midSizePicture)
                    .padding(proxy.frame(in: .global).maxY * 0.07)
                
                EditAccount(
                    name: $viewModel.name,
                    email: $viewModel.email,
                    password: $viewModel.password,
                    confirmPassword: $viewModel.confirmPassword,
                    isLoading: $viewModel.isLoading,
                    buttonLabel: "Create"
                ) {
                    viewModel.createAccount { signupResponse, privateKey, session in
                        try accessHandler.fillStorange(
                            with: signupResponse,
                            privateKey: privateKey,
                            context: self.modelContext,
                            session: session
                        )
                    }
                }
                .navigationTitle("Create Account")
                .navigationBarTitleDisplayMode(.inline)
                .appAlert(alert: $viewModel.error) { }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CreateAccountView()
            .environment(AccessHandler())
            .modelContext(ModelContext.inMemoryModelContext)
    }
}
