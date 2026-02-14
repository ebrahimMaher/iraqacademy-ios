//
//  UserVerificationViewModel.swift
//  iacademy
//
//  Created by Marwan Osama on 11/02/2026.
//

import Foundation

@MainActor
class UserVerificationViewModel {
    
    private let userVerificationUseCase: UserVerificationUseCase
    
    var didReceiveError: ((String) -> ())?
    var didReceiveLoading: ((Bool) -> ())?
    var didReceiveTelegramLink: ((String) -> ())?
    
    init(userVerificationUseCase: UserVerificationUseCase = UserVerificationUseCaseImpl.init()) {
        self.userVerificationUseCase = userVerificationUseCase
    }
    
    
    func fetchTelegramLink() {
        Task {
            didReceiveLoading?(true)
            defer { didReceiveLoading?(false) }
            do {
                let link = try await userVerificationUseCase.execute()
                didReceiveTelegramLink?(link)
            } catch {
                handleErrors(error)
            }
            
        }
    }
    
    private func handleErrors(_ error: Error) {
        guard let error = error as? NetworkError else {
            didReceiveError?(error.localizedDescription)
            return
        }
        didReceiveError?(error.description)
        
    }
    
    
}
