//
//  AdminMenu.swift
//  CupcakeCornerForAdmin
//
//  Created by Isaque da Silva on 4/16/25.
//

import SwiftUI

struct AdminMenuView: View {
    @State private var cupcakeRepository: CupcakeRepository
    @State private var isShowingCreateNewCupcake = false
    
    var body: some View {
        NavigationStack {
            MenuView(cupcakeRepository: cupcakeRepository)
                .navigationDestination(for: Cupcake.self) { cupcake in
                    CupcakeDetailView(cupcake: cupcake) { action in
                        try cupcakeRepository.updateStorage(with: action)
                    }
                }
                .toolbar {
                    Button {
                        isShowingCreateNewCupcake = true
                    } label: {
                        Icon.plusCircle.systemImage
                    }
                }
                .sheet(isPresented: $isShowingCreateNewCupcake) {
                    CreateNewCupcakeView { newCupcake in
                        try cupcakeRepository.updateStorage(
                            with: .create(newCupcake)
                        )
                    }
                }
        }
    }
    
    init(isPreview: Bool = false) {
        self._cupcakeRepository = .init(initialValue: .init(isPreview: isPreview))
    }
}

#Preview {
    AdminMenuView(isPreview: true)
}
