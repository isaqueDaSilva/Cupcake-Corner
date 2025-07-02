//
//  MenuListVC.swift
//  CupcakeCorner
//
//  Created by Isaque da Silva on 6/28/25.
//

import UIKit

final class MenuListVC: UITableViewController, UITableViewDataSourcePrefetching {
    private let refresh = UIRefreshControl()
    
    private let cellIdentifier = "CardTableViewCell"
    private let progressCellIdentifier = "ProgressViewTableViewCell"
    private let viewModel: MenuViewModel
    private var isRefreshing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        self.tableView.delegate = self
        self.tableView.refreshControl = self.refresh
        self.configureRefreshControl()
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
        print(indexPaths.count, indexPaths.last?.row)
        guard self.viewModel.viewState == .default && !self.isRefreshing else { return }
        
        if viewModel.cupcakes.count == indexPaths.last?.row {
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
extension MenuListVC {
    private func configureTableView() {
        self.tableView.register(
            CardTableViewCell.self,
            forCellReuseIdentifier: self.cellIdentifier
        )
        
        self.tableView.register(
            ProgressTableViewCell.self,
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
    
    private func setProgressViewCell(for indexPath: IndexPath) -> ProgressTableViewCell {
        let cell = self.tableView.dequeueReusableCell(
            withIdentifier: self.progressCellIdentifier,
            for: indexPath
        ) as! ProgressTableViewCell
        
        cell.startAnimating()
        
        return cell
    }
}

// MARK: Refresh Control
extension MenuListVC {
    private func configureRefreshControl() {
        self.tableView.refreshControl?.addTarget(
            self,
            action: #selector(self.refreshList),
            for: .valueChanged
        )
    }
}

// MARK: - Actions -
extension MenuListVC {
    @objc private func  refreshList() {
        self.isRefreshing = true
        self.tableView.refreshControl?.beginRefreshing()
        self.viewModel.removeCupcakes()
        self.tableView.reloadData()
        self.fetchCupcakes()
    }
    
    private func fetchCupcakes() {
        Task { [weak self] in
            guard let self else { return }
            await self.viewModel.fechMocks(isRefreshing: self.isRefreshing)
            print("finished")
            await MainActor.run {
                self.tableView.reloadData()
                
                if self.isRefreshing {
                    self.tableView.refreshControl?.endRefreshing()
                    self.isRefreshing = false
                }
            }
        }
    }
}

#Preview {
    MenuListVC(viewModel: .init(isPreview: false))
}
