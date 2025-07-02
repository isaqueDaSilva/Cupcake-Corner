//
//  MenuViewListVC.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 6/28/25.
//

import UIKit

final class MenuViewListVC: UITableViewController, UITableViewDataSourcePrefetching {
    private let cellIdentifier = "CardTableViewCell"
    private let progressCellIdentifier = "ProgressViewTableViewCell"
    private let viewModel: MenuViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.fetchCupcakes()
        self.configureTableView()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cupcakesCount = viewModel.cupcakes.count
        let sectionsCount = (viewModel.viewState == .loadedAll) ? (cupcakesCount) : (cupcakesCount + 1)
        return (cupcakesCount > 0) ? sectionsCount : 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row != viewModel.cupcakes.count {
            return self.setCupcakeCell(for: indexPath)
        } else {
            return self.setProgressViewCell(for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard viewModel.viewState == .default else { return }
        
        if (viewModel.cupcakes.last != nil) && (indexPaths.last != nil) {
            print("Start Fetching...")
            self.fetchCupcakes()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewModel.selectedCupcake = self.viewModel.cupcakes[indexPath.row]
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
    
    init(viewModel: MenuViewModel) {
        self.viewModel = viewModel
        
        super.init(style: .plain)
        
        self.tableView.separatorColor = .clear
    }
}

// MARK: - Cell Configuration -
extension MenuViewListVC {
    private func configureTableView() {
        self.tableView.register(
            CardTableViewCell.self,
            forCellReuseIdentifier: self.cellIdentifier
        )
        
        self.tableView.register(
            ProgressViewTableViewCell.self,
            forCellReuseIdentifier: self.progressCellIdentifier
        )
        
        self.tableView.prefetchDataSource = self
    }
    
    private func setCupcakeCell(for indexPath: IndexPath) -> CardTableViewCell {
        let cell = self.tableView.dequeueReusableCell(
            withIdentifier: self.cellIdentifier,
            for: indexPath
        ) as! CardTableViewCell
        
        let cupcake = self.viewModel.cupcakes[indexPath.row]
        
        cell.setElements(for: cupcake)
        
        return cell
    }
    
    private func setProgressViewCell(for indexPath: IndexPath) -> ProgressViewTableViewCell {
        let cell = self.tableView.dequeueReusableCell(
            withIdentifier: self.progressCellIdentifier,
            for: indexPath
        ) as! ProgressViewTableViewCell
        
        cell.startAnimating()
        
        return cell
    }
}

// MARK: - Actions -
extension MenuViewListVC {
    private func fetchCupcakes() {
        Task { [weak self] in
            guard let self else { return }
            await self.viewModel.fechMocks()
            
            await MainActor.run {
                self.tableView.reloadData()
            }
        }
    }
}

#Preview {
    MenuViewListVC(viewModel: .init(isPreview: false))
}
