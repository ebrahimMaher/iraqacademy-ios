//
//  SettingViewModel.swift
//  iacademy
//
//  Created by Marwan Osama on 15/12/2025.
//

import Foundation

class SettingViewModel {
    
    var didReceiveError: ((String) -> ())?
    var didReceiveLoading: ((Bool) -> ())?
    var didReceiveDeleteSuccessResponse: (() -> ())?

    func logout() {
        didReceiveLoading?(true)
        NetworkClient.shared.request(api: .logout, modelType: String.self) { [weak self] result in
            guard let self = self else { return }
            didReceiveLoading?(false)
            switch result {
            case .success(let response):
                if response.lowercased() == "true" || response == "1" {
                    CacheClient.shared.clearAll()
                    AppCoordinator.shared.setRoot(to: .login)
                }
            case .failure(let error):
                didReceiveError?(error.description)
            }
        }
    }
    
    func deleteAccount(reason: String) {
        didReceiveLoading?(true)
        NetworkClient.shared.request(api: .deleteAccount(reason: reason), modelType: DeleteAccountResponseModel.self) { [weak self] result in
            guard let self = self else { return }
            didReceiveLoading?(false)
            switch result {
            case .success(let deleteResponse):
                if let status = deleteResponse.status, !status.isEmpty {
                    didReceiveDeleteSuccessResponse?()
                }
            case .failure(let error):
                didReceiveError?(error.description)
            }
        }
    }
}
