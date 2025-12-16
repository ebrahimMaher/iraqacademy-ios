//
//  AppEntryPointVC.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import UIKit

//4CB10783-F51A-4C11-AC07-D11F5DB1F8CC

class AppEntryPointVC: UIViewController {
    
    private var viewModel = AppEntryPointViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

//        CacheClient.shared.clearAll()
        bind()
        viewModel.setupSecuritySuite()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if viewModel.isSecurityBreached { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.viewModel.fetchAppInfo()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.appDelegate.capturedChange() // to check if the user started recording screen before opening the application
    }
    
    private func bind() {
        viewModel.didSecurityStatusChange = { [weak self] status in
            guard let self = self else { return }
            if status == .restricted {
                self.applySecurityRestrictions()
            } else {
                self.removeSecurityRestrictions()
            }
        }
        
        viewModel.didReceiveReportSuccessResponse = { [weak self] in
            guard let self = self else { return }
            // once report is submitted, invalidate timer
            self.viewModel.securityCheckTimer?.invalidate()
        }
        
        viewModel.didReceiveAppInfo = { [weak self] appInfo in
            guard let self = self else { return }
            if appInfo.appIsDown ?? true {
                showSimpleAlert(title: "خطأ", message: "نواجه مشكلة مؤقتة، يرجى زيارة التطبيق لاحقًا.") {
                    self.viewModel.fetchAppInfo()
                }
            } else {
                CacheClient.shared.appInfo = appInfo
                if isAppVersionLatest(appInfo) {
                    handleRoot()
                } else {
                    showSimpleAlert(title: "تحديث", message: "تم توفر نسخة جديدة. يرجى التحديث إلى الإصدار الأحدث الآن.") {
                        self.viewModel.fetchAppInfo()
                        if let url = URL(string: appInfo.appleStoreURL ?? "") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
        }
        
        viewModel.didReceiveError = { [weak self] error in
            guard let self = self else { return }
            if error == .pinningFailed {
                SecuritySuite.shared.presentBlockerScreen()
                return
            }
            showSimpleAlert(title: "خطأ", message: error.description) {
                self.viewModel.fetchAppInfo()
            }
        }
    }
    
    private func isAppVersionLatest(_ appInfo: AppInfoModel) -> Bool {
        guard let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let stableVersion = appInfo.iosStableVersion else { return false }
        return currentVersion.compare(stableVersion, options: .numeric) != .orderedAscending
    }
    
    private func handleRoot() {
        let token = CacheClient.shared.authToken
        let isAccountVerified = CacheClient.shared.isAccountVerified
        
        if !token.isEmpty, isAccountVerified {
            setRootMain()
        } else {
            setRootLoginPage()
        }
    }
    
    private func isApp() {
        
    }
    
    private func setRootLoginPage() {
        AppCoordinator.shared.setRoot(to: .login)
    }
    
    private func setRootMain() {
        AppCoordinator.shared.setRoot(to: .main)
    }
    
    
    private func applySecurityRestrictions() {
        if viewModel.reportRequestModel.type == ViolationType.none.rawValue { return }
        viewModel.reportViolation()
        SecuritySuite.shared.presentBlockerScreen()
    }
        
    private func removeSecurityRestrictions() {
        SecuritySuite.shared.dismissIfBlockerVisible()
    }
}
