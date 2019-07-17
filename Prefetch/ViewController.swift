//
//  ViewController.swift
//  Prefetch
//
//  Created by Maple on 2019/7/5.
//  Copyright © 2019 Shanghai TanKe Network Technology Co., Ltd. All rights reserved.
//

import UIKit
private let reuseKey = "a"

enum RefreshState{
    case header
    case footer
}
class ViewController: UIViewController {
    var data = [Int]()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.frame, style: .plain)
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseKey)
        tableView.rowHeight = 200
        tableView.estimatedRowHeight = 1000
        let refreshControl = UIRefreshControl(frame: .zero)
        refreshControl.addTarget(self, action: #selector(refresh(control:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        return tableView
    }()
    
    @objc func refresh(control:UIRefreshControl){
        fetchData(.header)
    }
    
    func fetchData(_ state:RefreshState){
        guard !tableView.isPrefetchLoading else { return }
        tableView.isPrefetchLoading = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            switch state {
            case .header:
                self.data = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                self.tableView.refreshControl?.endRefreshing()
            case .footer:
                var last = self.data.last!
                for _ in 0..<6 {
                    last += 1
                    self.data.append(last)
                }
            }
            self.tableView.reloadData()
            self.tableView.isPrefetchLoading = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.isPrefetch = true
        tableView.prefetchBlock = { [weak self] in
            
        }
        tableView.remainRows = 5
    }
}

extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseKey, for: indexPath)
        cell.textLabel?.text = "\(data[indexPath.row])"
        return cell
    }
}


