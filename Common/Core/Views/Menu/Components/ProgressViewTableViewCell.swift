//
//  IndicatorTableViewCell.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 7/1/25.
//

import UIKit

class ProgressViewTableViewCell: UITableViewCell {
    private let progressView = UIActivityIndicatorView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configure()
        self.setConstraints()
    }
    
    @available(
        iOS,
        introduced: 18,
        deprecated: 18,
        message: "Not utilize this initializer."
    )
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ProgressViewTableViewCell {
    private func configure() {
        self.progressView.translatesAutoresizingMaskIntoConstraints = false
        self.progressView.style = .medium
        self.progressView.hidesWhenStopped = true
        self.addSubview(self.progressView)
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            self.progressView.leadingAnchor.constraint(
                equalTo: self.leadingAnchor
            ),
            self.progressView.trailingAnchor.constraint(
                equalTo: self.trailingAnchor
            ),
            self.progressView.topAnchor.constraint(
                equalTo: self.topAnchor
            ),
            self.progressView.bottomAnchor.constraint(
                equalTo: self.bottomAnchor
            )
        ])
    }
}

extension ProgressViewTableViewCell {
    func startAnimating() {
        self.progressView.startAnimating()
    }
    
    func stopAnimating() {
        self.progressView.stopAnimating()
    }
}

#Preview {
    let progressViewCell = ProgressViewTableViewCell()
    progressViewCell.stopAnimating()
    return progressViewCell
}
