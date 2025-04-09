//
//  MainRootView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import SwiftData
import ErrorWrapper
import SwiftUI

/// A main root that guides the app's flows from the ``SplashScreen`` to the ``HomeView``.
struct MainRootView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var isSplashViewPresented = true
    @State private var showError = false
    @State private var userRepository = UserRepository()
    @State private var error: ExecutionError? = nil
    
    var body: some View {
        Group {
            switch isSplashViewPresented {
            case true:
                SplashScreen(isSplashViewShowing: $isSplashViewPresented)
            case false:
                HomeView()
                    .environment(userRepository)
            }
        }
        .onAppear {
            do {
                try self.userRepository.load(with: self.modelContext)
            } catch {
                self.error = error as? ExecutionError
            }
        }
        .errorAlert(error: $error) { }
    }
}

#Preview {
    MainRootView()
        .environment(UserRepository())
        .modelContext(ModelContext.inMemoryModelContext)
}
