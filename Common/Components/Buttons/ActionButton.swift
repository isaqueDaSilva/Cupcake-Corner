//
//  ActionButton.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/10/25.
//

import SwiftUI

/// Sets a default action button to use throughout the app
struct ActionButton<Label: View, ActionButtonStyle: PrimitiveButtonStyle>: View {
    /// Indicates if this button is loading.
    @Binding var isLoading: Bool
    
    /// A textual representation of what this button makes.
    private let label: Label
    
    /// Indicates how much width this button has.
    private let width: CGFloat?
    
    /// Indicates how much heigh this button has.
    private let height: CGFloat?
    
    private let alignment: Alignment
    
    private let buttonStyle: ActionButtonStyle
    
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
            }
        }
        .buttonStyle(self.buttonStyle)
        .disabled(self.isLoading)
    }
    
    init(
        isLoading: Binding<Bool>,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        alignment: Alignment = .center,
        buttonStyle: ActionButtonStyle = BorderedProminentButtonStyle(),
        @ViewBuilder label: () -> Label,
        action: @escaping () -> Void
    ) {
        _isLoading = isLoading
        self.label = label()
        self.action = action
        self.width = width
        self.height = height
        self.alignment = alignment
        self.buttonStyle = buttonStyle
    }
}

extension ActionButton {
    private var buttonLabel: some View {
        HStack {
            switch isLoading {
            case true:
                ProgressView()
            case false:
                self.label
            }
        }
        .frame(maxWidth: width)
        .frame(height: height, alignment: self.alignment)
    }
}

#Preview {
    NavigationStack {
        VStack {
            ActionButton(isLoading: .constant(true)) {
                Text("Action")
            } action: { }.padding()
        }
        .toolbar {
            ActionButton(isLoading: .constant(false)) {
                Text("Action")
            } action: { }.padding()
        }
    }
}

#Preview {
    NavigationStack {
        VStack {
            ActionButton(isLoading: .constant(false)) {
                Text("Action")
            } action: { }.padding()
        }
        .toolbar {
            ActionButton(isLoading: .constant(true)) {
                Text("Action")
            } action: { }.padding()
        }
    }
}
