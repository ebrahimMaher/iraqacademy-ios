//
//  NotificationsVC.swift
//  iacademy
//
//  Created by Marwan Osama on 15/12/2025.
//

import UIKit
import CRRefresh

class NotificationsVC: UIViewController {

    @IBOutlet weak var itemsTV: UITableView!
    @IBOutlet weak var emptyStateView: UIView!
    
    private let viewModel = NotificationsViewModel()
    private let loadingView = LoadingView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        setupUI()
        viewModel.fetchMyNotifications()
    }

    private func bind() {
        viewModel.didReceiveError = { [weak self] error in
            guard let self = self else { return }
            showSimpleAlert(title: "خطأ", message: error)
        }
        
        viewModel.didReceiveLoading = { [weak self] loading in
            guard let self = self else { return }
            loadingView.isHidden = !loading
        }
        
        viewModel.didReceiveNotifications = { [weak self] in
            guard let self = self else { return }
            emptyStateView.isHidden = !viewModel.notifications.isEmpty
            itemsTV.cr.endHeaderRefresh()
            itemsTV.reloadData()
        }

    }
    
    private func setupUI() {
        loadingView.setup(in: view)
        emptyStateView.isHidden = true
        itemsTV.delegate = self
        itemsTV.dataSource = self
        itemsTV.register(NotificationTVCell.nib, forCellReuseIdentifier: NotificationTVCell.identifier)
        itemsTV.cr.addHeadRefresh(animator: FastAnimator()) { [weak self] in
            guard let self = self else { return }
            viewModel.initPages()
            viewModel.fetchMyNotifications()
        }
    }

}

extension NotificationsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTVCell.identifier, for: indexPath) as! NotificationTVCell
        cell.configure(viewModel.notifications[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.notifications.count - 1 {
            viewModel.fetchMyNotifications()
        }
    }
    
}
