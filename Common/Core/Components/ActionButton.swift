//
//  ActionButton.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/10/25.
//

import SwiftUI

/// Sets a default action button to use throughout the app
struct ActionButton: View {
    /// Indicates if this button is loading.
    @Binding var isLoading: Bool
    
    /// A textual representation of what this button makes.
    private let label: String
    
    /// Indicates how much width this button has.
    private let width: CGFloat?
    
    /// Indicates how much heigh this button has.
    private let height: CGFloat?
    
    /// Stores the action that this botton will be execcute.
    private var action: () -> Void
    
    var body: some View {
        Group {
            if #available(iOS 26.0, *) {
                Button(role: .confirm) {
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
                .buttonStyle(.borderedProminent)
            }
        }
        .disabled(self.isLoading)
    }
    
    init(
        isLoading: Binding<Bool>,
        label: String,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        action: @escaping () -> Void
    ) {
        _isLoading = isLoading
        self.label = label
        self.action = action
        self.width = width
        self.height = height
    }
}

extension ActionButton {
    private var buttonLabel: some View {
        HStack {
            switch isLoading {
            case true:
                ProgressView()
            case false:
                Text(label)
                    .bold()
            }
        }
        .frame(maxWidth: width)
        .frame(height: height, alignment: .center)
    }
}

#Preview {
    NavigationStack {
        VStack {
            ActionButton(
                isLoading: .constant(true),
                label: "Action",
                width: .infinity
            ) { }
                .padding()
        }
        .toolbar {
            ActionButton(
                isLoading: .constant(false),
                label: "Action"
            ) { }.padding()
        }
    }
}

#Preview {
    NavigationStack {
        VStack {
            ActionButton(
                isLoading: .constant(false),
                label: "Action"
            ) { }.padding()
        }
        .toolbar {
            ActionButton(
                isLoading: .constant(true),
                label: "Action",
            ) { }
                .padding()
        }
    }
}
