//
//  AboutCupcakeView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/10/25.
//

import SwiftUI

struct AboutCupcakeView: View {
    @Environment(\.dismiss) private var dismiss
    
    let flavor: String
    let coverImageData: Data
    let madeWithText: AttributedString
    let ingredientsText: AttributedString
    let dateDescriptionText: AttributedString
    let createAtText: AttributedString
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Image(by: coverImageData, with: .midHighPicture)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 150, maxHeight: 150)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                    
                    HStack(alignment: .center) {
                        Icon.infoCircle.systemImage
                            .font(.title2)
                            .bold()
                            .foregroundStyle(.blue)
                        Text("About the Cupcake")
                            .headerSessionText(font: .title2)
                    }
                    .padding(.bottom, 5)
                    
                    LabeledContent {
                        Text(ingredientsText)
                    } label: {
                        Text(madeWithText)
                    }

                    
//                    Text(madeWithText + ingredientsText)
//                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LabeledContent {
                        Text(dateDescriptionText)
                    } label: {
                        Text(createAtText)
                    }

                }
                .padding()
            }
            .navigationTitle(flavor)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let cupcake = Cupcake.mocks.first!.value
    
    AboutCupcakeView(
        flavor: cupcake.flavor,
        coverImageData: cupcake.coverImage,
        madeWithText: AttributedString("Made with"),
        ingredientsText: AttributedString("\(cupcake.ingredients)"),
        dateDescriptionText: AttributedString("3/10/25"),
        createAtText: AttributedString("3/5/25")
    )
}
