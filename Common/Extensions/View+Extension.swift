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
    /// Defines a error alert to be used when an ``AppError`` will be thrown.
    /// - Parameters:
    ///   - error: A binding value to reads the current state of the error.
    ///   - action: A ViewBuilder returning the alert’s actions to be executed when an error will thrown.
    @ViewBuilder
    func errorAlert(
        error: Binding<AppError?>,
        @ViewBuilder action: () -> some View
    ) -> some View {
        self
            .alert(
                error.wrappedValue?.title ?? "",
                isPresented: .init(get: {
                    // Reads the title and error description to check if one of those properties aren't nil.
                    // If bolth are empty and the error is nil, the value returned will be false,
                    // if bolth aren't empty and not nil the error, the value returned will be true.
                    ((error.wrappedValue?.title.isEmpty) != nil) && ((error.wrappedValue?.description.isEmpty) != nil)
                }, set: { _ in
                    // When the user taps some button of the alert the error state will be setup back as nil.
                    error.wrappedValue = nil
                })) {
                    action()
                } message: {
                    // Displays a message when the error description will be not nil.
                    if ((error.wrappedValue?.description.isEmpty) != nil) {
                        Text(error.wrappedValue?.description ?? "No Description Available right now.")
                    }
                }
    }
}
