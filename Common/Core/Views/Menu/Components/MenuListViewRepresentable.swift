//
//  MenuListViewRepresentable.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 6/30/25.
//

import SwiftUI

struct MenuListViewRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = MenuListVC
    
    @Binding var viewModel: MenuViewModel
    
    func makeUIViewController(context: Context) -> MenuListVC {
        .init(viewModel: viewModel)
    }
    
    func updateUIViewController(_ uiViewController: MenuListVC, context: Context) {
        
    }
}
