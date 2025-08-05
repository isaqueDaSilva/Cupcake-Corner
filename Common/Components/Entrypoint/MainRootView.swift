//
//  MainRootView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import SwiftData
import SwiftUI

/// A main root that guides the app's flows from the ``SplashScreen`` to the ``HomeView``.
struct MainRootView: View {
    private let logger = AppLogger(category: "MainRootView")
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var isSplashViewPresented = true
    @State private var showError = false
    @State private var accessHandler = AccessHandler()
    @State private var error: AppAlert? = nil
    
    var body: some View {
        HomeView()
            .environment(self.accessHandler)
            .opacity(self.isSplashViewPresented ? 0 : 1)
            .disabled(self.isSplashViewPresented)
            .overlay {
                if self.isSplashViewPresented {
                    SplashScreen(
                        isSplashViewShowing: self.$isSplashViewPresented
                    )
                }
            }
            .onAppear {
                do {
                    try self.accessHandler.load(
                        modelContext: self.modelContext,
                        session: .shared
                    )
                } catch {
                    self.logger.error("Error to load user from persistent storage. Error: \(error.localizedDescription)")
                }
            }
            .appAlert(alert: $error) { }
    }
}

#Preview {
    MainRootView()
        .modelContext(ModelContext.inMemoryModelContext)
}
