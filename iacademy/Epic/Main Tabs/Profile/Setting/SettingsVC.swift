//
//  SettingsVC.swift
//  iacademy
//
//  Created by Marwan Osama on 15/12/2025.
//

import UIKit

class SettingsVC: UIViewController {
    
    @IBOutlet weak var navigationHeader: NavigationHeader!
    
    @IBOutlet weak var notificationSW: UISwitch!
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var deleteView: UIView!
    
    private let viewModel = SettingViewModel()
    private let loadingView = LoadingView()

    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        setupUI()
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
        
        viewModel.didReceiveDeleteSuccessResponse = { [weak self] in
            guard let self = self else { return }
            showSimpleAlert(title: "تم بنجاح", message: "إن طلب حذف الحساب جاري مراجعته من الدعم\nربما تأخذ 24 ساعة لإتمام طلبك") {
                CacheClient.shared.clearAll()
                AppCoordinator.shared.setRoot(to: .login)
            }
        }
    }
    
    private func setupUI() {
        loadingView.setup(in: view)
        navigationHeader.title = "الإعدادات"
        configureTapGestures()
        setupNotificationSwitch()
    }
    
    private func configureTapGestures() {
        addTapGesture(to: logoutView, action: #selector(logoutTapped))
        addTapGesture(to: deleteView, action: #selector(deleteTapped))
    }

    private func addTapGesture(to view: UIView, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupNotificationSwitch() {
        notificationSW.transform = CGAffineTransform(scaleX: -1, y: 1)
        notificationSW.addTarget(self, action: #selector(onSwitchTap(_:)), for: .valueChanged)
        notificationSW.isOn = CacheClient.shared.settingsEnableNotification
    }
    
    @objc private func onSwitchTap(_ sender: UISwitch) {
        CacheClient.shared.settingsEnableNotification = sender.isOn
    }
    
    @objc private func logoutTapped() {
        viewModel.logout()
    }
    
    @objc private func deleteTapped() {
        let alert = UIAlertController(
            title: "هل أنت متأكد من أنك تريد حذف حسابك؟",
            message: "يرجى تزويدنا بسبب رغبتك في حذف الحساب. رأيك يهمنا لتحسين تجربتك.",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "سبب الحذف (اختياري)"
            textField.textAlignment = .right
        }

        let cancelAction = UIAlertAction(title: "إلغاء", style: .cancel)

        let deleteAction = UIAlertAction(title: "حذف الحساب", style: .destructive) { _ in
            let reason = alert.textFields?.first?.text ?? ""
            self.viewModel.deleteAccount(reason: reason)
        }

        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        present(alert, animated: true)
    }
}
