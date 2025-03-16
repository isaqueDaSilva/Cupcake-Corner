//
//  ActionButton.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/10/25.
//

import SwiftUI

struct ActionButton: View {
    @Binding var isLoading: Bool
    
    let label: String
    
    let width: CGFloat?
    let height: CGFloat?
    
    let isDisabled: Bool
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
