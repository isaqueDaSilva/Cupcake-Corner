//
//  SplashScreen.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import SwiftUI

struct SplashScreen: View {
    @Binding var isSplashViewShowing: Bool
    
    @State private var timerCount = 3
    @State private var cicleCount = 0
    @State private var scale = CGSize(width: 1, height: 1)
    @State private var viewOpacity: Double = 1
    @State private var cicleOpacity: Double = 1
    
    var body: some View {
        ZStack {
            Image(.appLogo)
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .scaleEffect(scale)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(cicleCount) / 2)
                .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .rotationEffect(Angle(degrees: -90))
                .animation(Animation.easeInOut(duration: 1), value: cicleCount)
                .opacity(cicleOpacity)
                .frame(width: 180, height: 180)
        }
        .opacity(viewOpacity)
        .onAppear {
            executeAnimation()
        }
    }
    
    private func executeAnimation() {
        Task { @MainActor in
            while timerCount > 0 {
                cicleCount += 1
                timerCount -= 1
                
                try? await Task.sleep(for: .seconds(1))
            }
            
            cicleOpacity = 0
            
            withAnimation(.easeInOut) {
                scale = .init(width: 50, height: 50)
                viewOpacity = 0
                isSplashViewShowing = false
            }
        }
    }
}

#Preview {
    SplashScreen(isSplashViewShowing: .constant(true))
}
