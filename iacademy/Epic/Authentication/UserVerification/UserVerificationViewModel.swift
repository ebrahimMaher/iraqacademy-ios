//
//  UserVerificationViewModel.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import Foundation

class UserVerificationViewModel {
    
    
    var didReceiveTelegramURL: ((String) -> ())?
    var didReceiveLoading: ((Bool) -> ())?
    var didReceiveError: ((String) -> ())?

    
    func fetchTelegramURL() {
        didReceiveLoading?(true)
        NetworkClient.shared.request(api: .telegramVerificationLink, modelType: String.self) { [weak self] result in
            guard let self = self else { return }
            didReceiveLoading?(false)
            switch result {
            case .success(let link):
                didReceiveTelegramURL?(link)
            case .failure(let error):
                didReceiveError?(error.description)
            }
        }
    }
    
    
}
