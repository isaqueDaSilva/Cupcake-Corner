//
//  GetPhoto.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 3/10/25.
//

import SwiftUI
import PhotosUI

enum GetPhoto {
    static func get(
        with pickerItemSelected: PhotosPickerItem,
        _ completation: @escaping (Data?) -> Void
    ) {
        pickerItemSelected.loadTransferable(type: Data.self) { result in
            switch result {
            case .success(let data):
                completation(data)
            case .failure(_):
                completation(nil)
            }
        }
    }
}
