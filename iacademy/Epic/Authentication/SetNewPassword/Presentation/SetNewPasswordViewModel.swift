//
//  SetNewPasswordViewModel.swift
//  iacademy
//
//  Created by Marwan Osama on 14/02/2026.
//

import Foundation

@MainActor
class SetNewPasswordViewModel {
    
    private let setNewPasswordUseCase: SetNewPasswordUseCase
    
    var didReceiveValidationError: ((_ error: String,_ isMoreThanOneError: Bool) -> ())?
    var didReceiveError: ((String) -> ())?
    var didReceiveLoading: ((Bool) -> ())?
    var didReceiveSuccess: (() -> ())?
    var didReceiveTokenExpired: ((String) -> ())?

    private var newPassword: String = ""
    private var confirmPassword: String = ""
    
    var isFormValid: Bool {
        let new = newPassword
        let confirm = confirmPassword
        return new.isValidPasswordLength && new == confirm
    }
    
    init(setNewPasswordUseCase: SetNewPasswordUseCase = SetNewPasswordUseCaseImpl()) {
        self.setNewPasswordUseCase = setNewPasswordUseCase
    }
    
    func setPasswordInputs(new: String, confirm:String) {
        newPassword = new
        confirmPassword = confirm
    }
    
    func setNewPassword(token: String) {
        Task {
            didReceiveLoading?(true)
            defer { didReceiveLoading?(false) }
            do {
                let _ = try await setNewPasswordUseCase.execute(token: token, password: newPassword)
                didReceiveSuccess?()
            } catch {
                handleErrors(error)
            }
        }
    }
}

//MARK: - error handling
extension SetNewPasswordViewModel {
    
    private func handleErrors(_ error: Error) {
        guard let error = error as? NetworkError else {
            didReceiveError?(error.localizedDescription)
            return
        }
        
        if case .validation(let errors) = error {
            didReceiveValidationError?(error.description, errors.count > 1)
        } else if case .passwordReset_TokenExpired = error {
            didReceiveTokenExpired?(error.description)
        } else {
            didReceiveError?(error.description)
        }
    }
}



