//
//  AppEntryPointViewModel.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import Foundation

enum SecurityStatus {
    case secure
    case restricted
}

enum ViolationType: String {
    case emulator = "emulator"
    case debugger = "debugging"
    case jailbreak = "root"
    case none = "none"
}

class AppEntryPointViewModel {
    
    var reportRequestModel: ReportViolationRequestModel = .init()
    
    
    var didReceiveReportSuccessResponse: (() -> ())?
    var didReceiveAppInfo: ((AppInfoModel) -> ())?
    var didReceiveError: ((NetworkError) -> ())?
    
    
    // Properties for app security
    var didSecurityStatusChange: ((SecurityStatus) -> ())?
    var isSecurityBreached: Bool = false
    var securityCheckTimer: Timer?
    
    
    deinit {
        securityCheckTimer?.invalidate()
    }


    func fetchAppInfo() {
        NetworkClient.shared.request(api: .appInfo, modelType: AppInfoModel.self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let appInfo):
                didReceiveAppInfo?(appInfo)
            case .failure(let error):
                didReceiveError?(error)
            }
        }
    }
    
    func reportViolation() {
        NetworkClient.shared.request(api: .reportViolation(reportRequestModel), modelType: ReportViolationResponseModel.self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let reportResponse):
                if let status = reportResponse.status, !status.isEmpty {
                    didReceiveReportSuccessResponse?()
                }
            case .failure(let error):
                didReceiveError?(error)
            }
        }
    }
}

// MARK: - App Security Setup
extension AppEntryPointViewModel {
    func setupSecuritySuite() {
        if Environment.isDebugBuild { return }
        performSecurityCheck()
        
        /// Setup periodic security checks every minute
        securityCheckTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.performSecurityCheck()
        }
    }
    
    private func performSecurityCheck() {
        let result = SecuritySuite.shared.performSecurityCheck()
        
        if result.isJailbroken {
            self.reportRequestModel.type = ViolationType.jailbreak.rawValue
        } else if result.isDebugged {
            self.reportRequestModel.type = ViolationType.debugger.rawValue
        } else if result.isEmulator {
            self.reportRequestModel.type = ViolationType.emulator.rawValue
        } else {
            self.reportRequestModel.type = ViolationType.none.rawValue
        }
        
        let status: SecurityStatus = result.isSecure ? .secure : .restricted
        isSecurityBreached = !result.isSecure
        didSecurityStatusChange?(status)
    }
}
