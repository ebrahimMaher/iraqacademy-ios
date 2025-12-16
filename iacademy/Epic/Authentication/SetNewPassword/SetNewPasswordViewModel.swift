//
//  SetNewPasswordViewModel.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import Foundation

class SetNewPasswordViewModel {
    
    var didReceiveValidationError: ((_ error: String,_ isMoreThanOneError: Bool) -> ())?
    var didReceiveError: ((String) -> ())?
    var didReceiveLoading: ((Bool) -> ())?
    var didReceiveSuccess: (() -> ())?
    var didReceiveTokenExpired: (() -> ())?

    
    private var newPassword: String = ""
    private var confirmPassword: String = ""
    
    var isFormValid: Bool {
        let new = newPassword
        let confirm = confirmPassword
        return new.isValidPasswordLength && new == confirm
    }
    
    func setPasswordInputs(new: String, confirm:String) {
        newPassword = new
        confirmPassword = confirm
    }
    
    func setNewPassword(token: String) {
        didReceiveLoading?(true)
        NetworkClient.shared.request(api: .passwordResetWithToken(token: token, password: newPassword), modelType: GenericSuccessResponseModel.self) { [weak self] result in
            guard let self = self else { return }
            didReceiveLoading?(false)
            switch result {
            case .success:
                didReceiveSuccess?()
            case .failure(let error):
                if case .validation(let errors) = error {
                    didReceiveValidationError?(error.description, errors.count > 1)
                } else if case .passwordReset_TokenExpired = error {
                    didReceiveTokenExpired?()
                } else {
                    didReceiveError?(error.description)
                }
            }
        }
    }
}
