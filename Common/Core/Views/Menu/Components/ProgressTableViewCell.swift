//
//  ProgressTableViewCell.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 7/1/25.
//

import UIKit

final class ProgressTableViewCell: UITableViewCell {
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

extension ProgressTableViewCell {
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
                equalTo: self.topAnchor, constant: 5
            ),
            self.progressView.bottomAnchor.constraint(
                equalTo: self.bottomAnchor, constant: -5
            )
        ])
    }
}

extension ProgressTableViewCell {
    func startAnimating() {
        self.progressView.startAnimating()
    }
    
    func stopAnimating() {
        self.progressView.stopAnimating()
    }
}

#Preview {
    let progressViewCell = ProgressTableViewCell()
    progressViewCell.stopAnimating()
    return progressViewCell
}
