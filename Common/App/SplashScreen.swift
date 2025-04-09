//
//  SplashScreen.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/9/25.
//

import SwiftUI

/// Shows an animation when the app is open.
struct SplashScreen: View {
    @Binding var isSplashViewShowing: Bool
    
    @State private var timerCount = 3
    @State private var cicleCount = 0
    @State private var scale = CGSize(width: 1, height: 1)
    @State private var viewOpacity: Double = 1
    @State private var cicleOpacity: Double = 1
    
    var body: some View {
        ZStack {
            LogoView(size: .midSizePicture)
                .scaleEffect(scale)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(cicleCount) / 2)
                .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .rotationEffect(Angle(degrees: -90))
                .animation(Animation.easeInOut(duration: 1), value: cicleCount)
                .opacity(cicleOpacity)
                .frame(width: 200, height: 200)
        }
        .opacity(viewOpacity)
        .onAppear {
            executeAnimation()
        }
    }
    
    /// Responsible to execute a loop that increments a circle until it's complete the full 360° round, when this view is removed from the screen.
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
