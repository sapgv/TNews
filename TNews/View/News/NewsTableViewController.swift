//
//  NewsTableViewController.swift
//  TNews
//
//  Created by Гриша on 12.12.2017.
//  Copyright © 2017 sapgv. All rights reserved.
//

import UIKit

class NewsTableViewController: UITableViewController {

    typealias CellType = NewsCell
    private var viewModel: NewsViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupTableView()
        setupBindings()
        refreshData()
    }

    private func setup() {
        let parser = Parser()
        let requestFactory = NetworkRequestFactory(baseURL: NetworkKeys.APIBaseURL)
        let requestPreparer = RequestPreparer(networkRequestFactory: requestFactory)
        
        let service = Service(requestPreparer: requestPreparer, parser: parser)
        viewModel = NewsViewModel(service: service)
    }

    private func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = CellType.estimatedHeight
        setupRefreshControl()
    }
    
    private func setupBindings() {
        viewModel.stateChanged = { [weak self] state in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                switch state {
                case .normal:
                    strongSelf.hideStatusHud()
                    strongSelf.refreshControl?.endRefreshing()
                case .cachedDataLoaded:
                    strongSelf.tableView.reloadData()
                case .successful:
                    strongSelf.hideStatusHud()
                    strongSelf.refreshControl?.endRefreshing()
                    strongSelf.tableView.reloadData()
                case .loading:
                    print("loading")
                    strongSelf.showStatusHud()
                case .error(let error):
                    strongSelf.hideStatusHud()
                    strongSelf.refreshControl?.endRefreshing()
                    strongSelf.showAlert(with: error)
                }
            }
        }
        
    }
    
    private func setupRefreshControl() {
        refreshControl?.attributedTitle = NSAttributedString(string: "Обновление")
        refreshControl?.addTarget(self, action: #selector(NewsTableViewController.refreshData), for: UIControlEvents.valueChanged)

        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.backgroundView = refreshControl
        }
    }
    
    public func refreshData() {
        viewModel.getNews()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return viewModel.numberOfPosts()
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellType.describing, for: indexPath)
        if let cell = cell as? CellType {
            cell.set(viewModel: viewModel.post(at: indexPath.row))
        }
        return cell
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showPost(at: indexPath)
    }
    
    fileprivate func showPost(at indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "PostViewController") as! PostViewController
        viewModel.configure(postViewModel: viewController.viewModel, at: indexPath.row)
        navigationController?.pushViewController(viewController, animated: true)
    }

}
