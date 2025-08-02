//
//  View+Extension.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/10/25.
//

import SwiftUI

// MARK: - Header Session Text -
struct HeaderSessionText: ViewModifier {
    private var font: Font
    private var fontWeight: Font.Weight
    private var color: Color
    
    func body(content: Content) -> some View {
        content
            .font(font)
            .fontWeight(fontWeight)
            .foregroundStyle(color)
    }
    
    init(font: Font, fontWeight: Font.Weight, color: Color) {
        self.font = font
        self.fontWeight = fontWeight
        self.color = color
    }
}

extension View {
    /// Makes the current text highlighted as header text.
    func headerSessionText(
        font: Font = .title2,
        fontWeight: Font.Weight = .bold,
        color: Color = .primary
    ) -> some View {
        self.modifier(
            HeaderSessionText(
                font: font,
                fontWeight: fontWeight,
                color: color
            )
        )
    }
}

// MARK: - Soft Background -
extension View {
    func softBackground() -> some View {
        self
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(Color(.systemGray5))
            }
    }
}

// MARK: - Error Alert -
extension View {
    @ViewBuilder
    func appAlert(
        alert: Binding<AppAlert?>,
        @ViewBuilder action: () -> some View
    ) -> some View {
        self
            .alert(
                alert.wrappedValue?.title ?? "",
                isPresented: .init(get: {
                    ((alert.wrappedValue?.title.isEmpty) != nil) && ((alert.wrappedValue?.description.isEmpty) != nil)
                }, set: { _ in
                    alert.wrappedValue = nil
                })) {
                    action()
                } message: {
                    if ((alert.wrappedValue?.description.isEmpty) != nil) {
                        Text(alert.wrappedValue?.description ?? "No Description Available right now.")
                    }
                }
    }
}
