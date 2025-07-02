//
//  MenuListViewRepresentable.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 6/30/25.
//

import SwiftUI

struct MenuListViewRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = MenuViewListVC
    
    @Binding var viewModel: MenuViewModel
    
    func makeUIViewController(context: Context) -> MenuViewListVC {
        .init(viewModel: viewModel)
    }
    
    func updateUIViewController(_ uiViewController: MenuViewListVC, context: Context) {
        
    }
}
