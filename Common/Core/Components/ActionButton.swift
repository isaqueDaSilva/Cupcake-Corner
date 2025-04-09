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
    let label: String
    
    /// Indicates how much width this button has.
    let width: CGFloat?
    
    /// Indicates how much heigh this button has.
    let height: CGFloat?
    
    /// Indicates if this button is current disable.
    let isDisabled: Bool
    
    /// Stores the action that this botton will be execcute.
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Group {
                switch isLoading {
                case true:
                    VStack {
                        ProgressView()
                    }
                    .frame(height: height, alignment: .center)
                case false:
                    VStack {
                        Text(label)
                            .bold()
                    }
                }
            }
            .frame(maxWidth: width)
            .frame(height: height, alignment: .center)
        }
        .disabled(isDisabled)
        .buttonStyle(.borderedProminent)
    }
    
    init(
        isLoading: Binding<Bool>,
        label: String,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        _isLoading = isLoading
        self.label = label
        self.action = action
        self.width = width
        self.height = height
        self.isDisabled = isDisabled
    }
}

#Preview {
    VStack {
        ActionButton(isLoading: .constant(false), label: "Action") { }
            .padding()
        
        ActionButton(isLoading: .constant(true), label: "Action", width: .infinity, isDisabled: true) { }
            .padding()
    }
}
