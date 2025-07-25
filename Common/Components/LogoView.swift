//
//  LogoView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//

import SwiftUI

struct LogoView: View {
    let size: CGSize
    
    var body: some View {
        Image(by: .appLogo, with: .highPicture)
            .resizable()
            .scaledToFit()
            .frame(
                width: size.width,
                height: size.height
            )
    }
    
    init(size: CGSize = .highPicture) {
        self.size = size
    }
}

#Preview {
    LogoView()
}
