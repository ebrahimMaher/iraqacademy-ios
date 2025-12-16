//
//  UserVerificationVC.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import UIKit
import WebKit
import SafariServices

class UserVerificationVC: UIViewController {
    
    private let loadingView = LoadingView()
    private let viewModel = UserVerificationViewModel()
    var safariVC: SFSafariViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        setupUI()

    }
    
    private func setupUI() {
        loadingView.setup(in: view)
        AppCoordinator.shared.removeFromNavigationStack(destination: .register)
    }
    
    private func clearSafariCache() {
        SFSafariViewController.DataStore.default.clearWebsiteData()

    }
    
    private func bind() {
        viewModel.didReceiveError = { [weak self] error in
            guard let self = self else { return }
            showAlertWithCancel(title: "خطأ", message: error.description, okActionName: "محاولة مرة أخري") {
                self.viewModel.fetchTelegramURL()
            }
        }
        
        viewModel.didReceiveLoading = { [weak self] loading in
            guard let self = self else { return }
            loadingView.isHidden = !loading
        }
        
        viewModel.didReceiveTelegramURL = { [weak self] link in
            guard let self = self else { return }
            beginTelegramOAuth(link: link)
        }
    }
    
    private func beginTelegramOAuth(link: String) {
        if let url = URL(string: link) {
            let safariVC = SFSafariViewController(url: url)
            safariVC.delegate = self
            self.safariVC = safariVC
            present(safariVC, animated: true)
        }
    }

    @IBAction func verifyTapped(_ sender: UIButton) {
        viewModel.fetchTelegramURL()
    }
    

}

extension UserVerificationVC: SFSafariViewControllerDelegate {
    
    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        print("Safari activityItemsFor \(URL.absoluteString) - title \(title)")
        return []
    }
    
    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        print("Safari initialLoadDidRedirectTo \(URL.absoluteString)")
    }
}

