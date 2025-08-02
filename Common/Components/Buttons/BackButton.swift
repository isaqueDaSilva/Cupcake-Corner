//
//  BackButton.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 6/19/25.
//

import SwiftUI

struct BackButton: View {
    var action: () -> Void
    
    var body: some View {
        if #available(iOS 26.0, *) {
            Button(role: .close) {
                self.action()
            } label: {
                self.buttonLabel
            }
        } else {
            Button {
                self.action()
            } label: {
                self.buttonLabel
            }
        }
    }
}

extension BackButton {
    private var buttonLabel: some View {
        HStack {
            Icon.chevronLeft.systemImage
            Text("Back")
        }
    }
}

#Preview {
    BackButton { }
}
