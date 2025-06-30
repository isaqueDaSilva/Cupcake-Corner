//
//  MenuViewListVC.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 6/28/25.
//

import UIKit

final class MenuViewListVC: UITableViewController, UITableViewDataSourcePrefetching {
    private let cellIdentifier = "CardTableViewCell"
    private let viewModel: MenuView.ViewModel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchCupcakes()
        self.configureTableView()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.cupcakes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(
            withIdentifier: self.cellIdentifier,
            for: indexPath
        ) as! CardTableViewCell
        
        let cupcake = self.viewModel.cupcakes[indexPath.row]
        
        cell.setElements(for: cupcake)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard viewModel.viewState == .default else { return }
        
        print(indexPaths.count)
        
        if (viewModel.cupcakes.last != nil) && (indexPaths.last != nil) {
            print("Start Fetching...")
            self.fetchCupcakes()
        }
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
    
    init(viewModel: MenuView.ViewModel) {
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
        
        self.tableView.prefetchDataSource = self
        self.tableView.isPrefetchingEnabled = true
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
