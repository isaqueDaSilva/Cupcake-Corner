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
        ZStack {
            // TODO: Add a transition effect between Splash Screen and the HomeView.
            HomeView()
                .environment(userRepository)
                .opacity(isSplashViewPresented ? 0 : 1)
                .disabled(isSplashViewPresented)
                .overlay {
                    if isSplashViewPresented {
                        SplashScreen(
                            isSplashViewShowing: $isSplashViewPresented
                        )
                    }
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
