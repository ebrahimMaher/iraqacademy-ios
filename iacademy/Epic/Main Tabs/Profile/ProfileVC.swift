//
//  ProfileVC.swift
//  iacademy
//
//  Created by Marwan Osama on 15/12/2025.
//

import UIKit
import CRRefresh

class ProfileVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var specialityLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var helpView: UIView!
    
    private let loadingView = LoadingView()
    private let viewModel = ProfileViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        setupUI()
        viewModel.fetchMyProfile()
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
        
        viewModel.didReceiveProfileResponse = { [weak self] profileResponse in
            guard let self = self else { return }
            scrollView.cr.endHeaderRefresh()
            handleProfileResponse(profileResponse)
        }
    }
    
    private func setupUI() {
        configureLoading()
        configureEditButton()
        configureTapGestures()
        configurePullToRefresh()
    }
    
    private func configureLoading() {
        loadingView.setup(in: view)
        contentView.isHidden = true
    }
    
    private func configureEditButton() {
        editButton.semanticContentAttribute = .forceRightToLeft
        editButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: -3)
        editButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -3, bottom: 0, right: 3)
        editButton.titleLabel?.font = UIFont.rubikFont(weight: .medium, size: 14)
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
    }
    
    private func configureTapGestures() {
        addTapGesture(to: editView, action: #selector(editTapped))
        addTapGesture(to: passwordView, action: #selector(passwordTapped))
        addTapGesture(to: settingsView, action: #selector(settingsTapped))
        addTapGesture(to: helpView, action: #selector(helpTapped))
    }

    private func addTapGesture(to view: UIView, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
    }
    
    private func configurePullToRefresh() {
        scrollView.cr.addHeadRefresh(animator: FastAnimator()) { [weak self] in
            self?.viewModel.fetchMyProfile()
        }
    }
    
    @objc private func editTapped() {
        AppCoordinator.shared.navigate(to: .editProfile(onUpdate: { [weak self] in
            guard let self = self else { return }
            if let updatedUser = CacheClient.shared.userModel {
                self.populateUserData(updatedUser)
            }
        }))
    }
    
    @objc private func passwordTapped() {
        AppCoordinator.shared.navigate(to: .changePassword)
    }
    
    @objc private func settingsTapped() {
        AppCoordinator.shared.navigate(to: .settings)
    }
    
    @objc private func helpTapped() {
        if let telegramURL = CacheClient.shared.appInfo?.telegramURL,
           let url = URL(string: telegramURL),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func handleProfileResponse(_ profileResponse: ProfileResponseModel) {
        guard let user = profileResponse.user else { return }
        CacheClient.shared.userModel = user
        populateUserData(user)
    }
    
    private func populateUserData(_ user: UserModelResponse) {
        contentView.isHidden = false
        userNameLabel.text = user.name ?? ""
        specialityLabel.text = user.speciality?.name ?? "-"
        profileImageView.kf.setImage(with: URL(string: user.avatar ?? ""), placeholder: UIImage(named: "profile_placeholder"), options: [.transition(.fade(0.3)), .cacheMemoryOnly])
    }
}
