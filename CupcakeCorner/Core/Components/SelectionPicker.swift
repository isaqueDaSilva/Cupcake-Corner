//
//  SelectionPicker.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/16/25.
//

import SwiftUI

struct SelectionPicker<Label: View>: View {
    @Binding var isActive: Bool
    
    @ViewBuilder var label: Label
    
    var body: some View {
        Button {
            withAnimation(.spring) {
                $isActive.wrappedValue.toggle()
            }
        } label: {
            label
                .selectionStyle {
                    isActive ? Color.blue : Color(uiColor: .systemGray3)
                }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SelectionPicker(isActive: .constant(false)) {
        HStack {
            LabeledContent(
                "Price",
                value: 30,
                format: .currency(code: "USD")
            )
        }
    }
    .padding()
}
