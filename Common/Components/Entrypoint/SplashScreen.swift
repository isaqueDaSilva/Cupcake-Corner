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
                .scaleEffect(self.scale)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(self.cicleCount) / 2)
                .stroke(
                    style: StrokeStyle(
                        lineWidth: 3, lineCap: .round, lineJoin: .round
                    )
                )
                .rotationEffect(Angle(degrees: -90))
                .animation(Animation.easeInOut(duration: 1), value: self.cicleCount)
                .opacity(self.cicleOpacity)
                .frame(width: 200, height: 200)
        }
        .opacity(self.viewOpacity)
        .onAppear {
            self.executeAnimation()
        }
    }
    
    /// Responsible to execute a loop that increments a circle until it's complete the full 360° round, when this view is removed from the screen.
    private func executeAnimation() {
        Task { @MainActor in
            while timerCount > 0 {
                self.cicleCount += 1
                self.timerCount -= 1
                
                try? await Task.sleep(for: .seconds(1))
            }
            
            self.cicleOpacity = 0
            
            withAnimation(.easeInOut) {
                self.scale = .init(width: 50, height: 50)
                self.viewOpacity = 0
                self.isSplashViewShowing = false
            }
        }
    }
}

#Preview {
    SplashScreen(isSplashViewShowing: .constant(true))
}
