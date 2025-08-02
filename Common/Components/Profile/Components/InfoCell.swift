//
//  UserInfoCell.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 7/31/25.
//

import SwiftUI

extension ProfileView {
    struct InfoCell: View {
        let labelName: String
        let text: String
        
        var body: some View {
            LabeledContent {
                Text(self.text)
            } label: {
                Text(self.labelName)
            }
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .softBackground()
        }
    }
}

#Preview {
    ProfileView.InfoCell(labelName: "Name", text: "Tim Cook")
}
