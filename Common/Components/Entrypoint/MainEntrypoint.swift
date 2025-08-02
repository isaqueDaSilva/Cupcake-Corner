//
//  MainEntrypoint.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import SwiftData
import SwiftUI

/// A main entry level point to access the internals of the application.
struct MainEntrypoint: Scene {
    var body: some Scene {
        WindowGroup {
            MainRootView()
        }
        .modelContainer(for: User.self)
    }
}
