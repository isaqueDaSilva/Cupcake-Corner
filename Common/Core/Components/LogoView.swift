//
//  LogoView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//

import SwiftUI

struct LogoView: View {
    var body: some View {
        Image(by: .appLogo, with: .highPicture)
            .resizable()
            .scaledToFit()
            .frame(
                width: CGSize.highPicture.width,
                height: CGSize.highPicture.height
            )
    }
}

#Preview {
    LogoView()
}
