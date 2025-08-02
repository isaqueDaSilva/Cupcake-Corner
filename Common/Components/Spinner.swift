//
//  Spinner.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 8/2/25.
//

import SwiftUI

struct Spinner: View {
    let currentViewState: ViewState
    var body: some View {
        Group {
            if self.currentViewState == .fetchingMore {
                ProgressView()
            }
        }
    }
}

#Preview {
    Spinner(currentViewState: .fetchingMore)
}
