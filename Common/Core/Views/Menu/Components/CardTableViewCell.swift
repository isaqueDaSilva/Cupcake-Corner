//
//  CardTableViewCell.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 6/28/25.
//

import UIKit

final class CardTableViewCell: UITableViewCell {
    private let cupcakeImageView = UIImageView()
    private let flavorNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let progressView = UIActivityIndicatorView()
    
    private let vStack = UIStackView()
    private let hStack = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configureView()
    }
    
    @available(
        iOS,
        introduced: 18,
        deprecated: 18,
        message: "Not utilize this initializer."
    )
    required init?(coder: NSCoder) {
        fatalError("Initializer `init?(coder: NSCoder)` not configured.")
    }
}

// MARK: - Configure UI Elements -

extension CardTableViewCell {
    private func configureView() {
        self.configureProgressView()
        self.configureCupcakeImageView()
        self.configureFlavorNameLabel()
        self.configureDescriptionLabel()
        self.configureVStack()
        self.configureHStack()
        
        self.contentView.addSubview(hStack)
        
        self.setHStackConstraints()
        self.setProgressViewConstrains()
        self.setImageConstraints()
    }
    
    private func configureCupcakeImageView() {
        self.cupcakeImageView.translatesAutoresizingMaskIntoConstraints = false
        self.cupcakeImageView.contentMode = .scaleAspectFit
        self.cupcakeImageView.layer.cornerRadius = 10
        self.cupcakeImageView.backgroundColor = .systemBackground
    }
    
    private func configureProgressView() {
        self.progressView.translatesAutoresizingMaskIntoConstraints = false
        self.progressView.style = .medium
        self.progressView.hidesWhenStopped = true
        self.progressView.backgroundColor = .systemBackground
        self.progressView.layer.cornerRadius = 10
    }
    
    private func configureFlavorNameLabel() {
        self.flavorNameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.flavorNameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.flavorNameLabel.textColor = .label
        self.flavorNameLabel.numberOfLines = 1
    }
    
    private func configureDescriptionLabel() {
        self.descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        self.descriptionLabel.textColor = .secondaryLabel
        self.descriptionLabel.numberOfLines = 2
    }
    
    private func configureVStack() {
        self.vStack.translatesAutoresizingMaskIntoConstraints = false
        self.vStack.axis = .vertical
        self.vStack.spacing = 5
        self.vStack.alignment = .leading
        self.vStack.addArrangedSubview(self.flavorNameLabel)
        self.vStack.addArrangedSubview(self.descriptionLabel)
    }
    
    private func configureHStack() {
        self.hStack.translatesAutoresizingMaskIntoConstraints = false
        self.hStack.axis = .horizontal
        self.hStack.spacing = 10
        self.hStack.alignment = .center
        self.hStack.backgroundColor = .systemGray3
        self.hStack.layer.cornerRadius = 10
        
        self.hStack.addArrangedSubview(self.progressView)
        self.hStack.addArrangedSubview(self.cupcakeImageView)
        self.hStack.addArrangedSubview(self.vStack)
    }
    
    private func setHStackConstraints() {
        NSLayoutConstraint.activate([
            self.hStack.leadingAnchor.constraint(
                equalTo: self.contentView.leadingAnchor, constant: 12
            ),
            self.hStack.trailingAnchor.constraint(
                equalTo: self.contentView.trailingAnchor, constant: -12
            ),
            self.hStack.topAnchor.constraint(
                equalTo: self.contentView.topAnchor, constant: 5
            ),
            self.hStack.bottomAnchor.constraint(
                equalTo: self.contentView.bottomAnchor, constant: -5
            )
        ])
    }
    
    private func setImageConstraints() {
        NSLayoutConstraint.activate([
            self.cupcakeImageView.leadingAnchor.constraint(
                equalTo: self.hStack.leadingAnchor, constant: 5
            ),
            self.cupcakeImageView.topAnchor.constraint(
                equalTo: self.hStack.topAnchor, constant: 5
            ),
            self.cupcakeImageView.bottomAnchor.constraint(
                equalTo: self.hStack.bottomAnchor, constant: -5
            ),
            self.cupcakeImageView.widthAnchor.constraint(
                equalToConstant: CGSize.smallSize.width
            ),
            self.cupcakeImageView.heightAnchor.constraint(
                equalToConstant: CGSize.smallSize.height
            )
        ])
    }
    
    private func setProgressViewConstrains() {
        NSLayoutConstraint.activate([
            self.progressView.leadingAnchor.constraint(
                equalTo: self.hStack.leadingAnchor, constant: 5
            ),
            self.progressView.topAnchor.constraint(
                equalTo: self.hStack.topAnchor, constant: 5
            ),
            self.progressView.bottomAnchor.constraint(
                equalTo: self.hStack.bottomAnchor, constant: -5
            ),
            self.progressView.widthAnchor.constraint(
                equalToConstant: CGSize.smallSize.width
            ),
            self.progressView.heightAnchor.constraint(
                equalToConstant: CGSize.smallSize.height
            )
        ])
    }
}

// MARK: - Set elements -
extension CardTableViewCell {
    func setElements(for cupcake: ReadCupcake) {
        self.flavorNameLabel.text = cupcake.flavor + " - " + cupcake.price.toCurreny
        self.descriptionLabel.text = "Made with " + cupcake.ingredients.joined(
            separator: ","
        )
        
        if let id = cupcake.id {
            self.setImage(for: id.uuidString)
        }
    }
    
    private func setImage(for cupcakeID: String) {
        self.cupcakeImageView.isHidden = true
        self.progressView.startAnimating()
        Task {
            do {
//                let token = try TokenGetter.getValue()
//                let (data, response) = try await CupcakeImage.getImage(
//                    with: cupcakeID,
//                    token: token,
//                    session: .shared
//                )
//                
//                guard response.status == .ok else {
//                    throw URLError(.badServerResponse)
//                }
//                
//                let cupcakeImageRepresentation = try JSONDecoder().decode(
//                    CupcakeImage.self,
//                    from: data
//                )
                try await Task.sleep(for: .seconds(3))
                
                await MainActor.run {
                    self.cupcakeImageView.image = /*.init(
                        data: cupcakeImageRepresentation.imageData
                                                   )*/ .appLogo.resizer(with: .smallSize)
                    
                    self.progressView.stopAnimating()
                    self.cupcakeImageView.isHidden = false
                }
            } catch {
                await MainActor.run {
                    self.cupcakeImageView.image = Icon
                        .exclamationmarkTriangleFill
                        .uiSystemImage?
                        .resizer(with: .smallSize)
                }
            }
        }
    }
}

#Preview {
    let cardCell = CardTableViewCell()
    cardCell.setElements(for: .init())
    
    return cardCell
}
