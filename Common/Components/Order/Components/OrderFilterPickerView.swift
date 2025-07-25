//
//  OrderFilterPickerView.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/13/25.
//


import SwiftUI

struct OrderFilterPickerView: View {
    @Binding var filter: Status
    
    var body: some View {
        Picker("Orders", selection: $filter) {
            ForEach(Status.allCases, id: \.id) { status in
                Text(status.displayedName)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.bottom, 5)
    }
}

#Preview {
    OrderFilterPickerView(filter: .constant(.ordered))
}
