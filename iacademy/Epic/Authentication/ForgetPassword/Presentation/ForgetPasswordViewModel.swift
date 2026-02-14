//
//  ForgetPasswordViewModel.swift
//  iacademy
//
//  Created by Marwan Osama on 14/02/2026.
//

import Foundation

@MainActor
class ForgetPasswordViewModel {
    
    private let forgetPasswordUseCase: ForgetPasswordUseCase
    
    var didReceiveError: ((String) -> ())?
    var didReceiveLoading: ((Bool) -> ())?
    var didReceiveVerificationLink: ((String) -> ())?
    var didReceiveValidationError: ((_ error: String,_ isMoreThanOneError: Bool) -> ())?
    
    init(forgetPasswordUseCase: ForgetPasswordUseCase = ForgetPasswordUseCaseImpl()) {
        self.forgetPasswordUseCase = forgetPasswordUseCase
    }
    
    func forgetPasswordVerify(phone: String) {
        Task {
            didReceiveLoading?(true)
            defer { didReceiveLoading?(false) }
            do {
                let response = try await forgetPasswordUseCase.execute(phone: phone)
                didReceiveVerificationLink?(response.url ?? "")
            } catch {
                handleErrors(error)
            }
        }
    }
}

//MARK: - error handling
extension ForgetPasswordViewModel {
    
    private func handleErrors(_ error: Error) {
        guard let error = error as? NetworkError else {
            didReceiveError?(error.localizedDescription)
            return
        }
        
        if case .validation(let errors) = error {
            didReceiveValidationError?(error.description, errors.count > 1)
        } else {
            didReceiveError?(error.description)
        }
    }
}
