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

@MainActor
class AppEntryPointViewModel {
    
    let appInfoUseCase: AppInfoUseCase
    let reportViolationUseCase: ReportViolationUseCase
    var reportRequestModel: ReportViolationRequestModel = .init()
    
    
    var didReceiveReportSuccessResponse: (() -> ())?
    var didReceiveAppInfo: ((AppInfoModel) -> ())?
    var didReceiveError: ((NetworkError) -> ())?
    
    
    // Properties for app security
    var didSecurityStatusChange: ((SecurityStatus) -> ())?
    var isSecurityBreached: Bool = false
    var securityCheckTimer: Timer?
    
    init(appInfoUseCase: AppInfoUseCase = AppInfoUseCaseImpl.init(),
         reportViolationUseCase: ReportViolationUseCase = ReportViolationUseCaseImpl.init()) {
        self.appInfoUseCase = appInfoUseCase
        self.reportViolationUseCase = reportViolationUseCase
    }
    
    deinit {
        securityCheckTimer?.invalidate()
    }


    func fetchAppInfo() {
        Task {
            do {
                let response = try await appInfoUseCase.execute()
                didReceiveAppInfo?(response)
            } catch {
                handleErrors(error)
            }
        }
    }
    
    func reportViolation() {
        Task {
            do {
                let response = try await reportViolationUseCase.execute(reportRequestModel)
                didReceiveReportSuccessResponse?()
            } catch {
                handleErrors(error)
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
            Task { @MainActor in
                self?.performSecurityCheck()
            }
            
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

extension AppEntryPointViewModel {
    
    private func handleErrors(_ error: Error) {
        guard let error = error as? NetworkError else {
            print(error.localizedDescription)
            return
        }
        didReceiveError?(error)
    }
}
