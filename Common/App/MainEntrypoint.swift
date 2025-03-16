//
//  MainEntrypoint.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import SwiftData
import SwiftUI

struct MainEntrypoint: Scene {
    var body: some Scene {
        WindowGroup {
            MainRootView()
            
        }
        .modelContainer(for: User.self)
    }
}
