//
//  IndicatorTableViewCell.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 7/1/25.
//

import UIKit

class ProgressViewTableViewCell: UITableViewCell {
    private let progressView = UIActivityIndicatorView()
    
    private func configure() {
        self.progressView.translatesAutoresizingMaskIntoConstraints = false
        self.progressView.style = .medium
        self.progressView.hidesWhenStopped = true
    }
}

#Preview {
    ProgressViewTableViewCell()
}
