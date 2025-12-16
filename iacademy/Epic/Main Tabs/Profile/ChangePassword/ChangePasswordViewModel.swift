//
//  ChangePasswordViewModel.swift
//  iacademy
//
//  Created by Marwan Osama on 15/12/2025.
//

import Foundation

class ChangePasswordViewModel {
    
    var changePasswordRequestModel: ChangePasswordRequestModel = .init()
    
    var didReceiveValidationError: ((_ error: String,_ isMoreThanOneError: Bool) -> ())?
    var didReceiveError: ((String) -> ())?
    var didReceiveLoading: ((Bool) -> ())?
    var didReceiveSuccess: (() -> ())?
    
    private var confirmPassword: String = ""
    
    var isFormValid: Bool {
        let old = changePasswordRequestModel.current_password
        let new = changePasswordRequestModel.password
        let confirm = confirmPassword
        return old.isValidPasswordLength && new.isValidPasswordLength && new == confirm
    }
    
    func setPasswordInputs(old: String, new: String, confirm:String) {
        changePasswordRequestModel.current_password = old
        changePasswordRequestModel.password = new
        confirmPassword = confirm
    }
    
    func changePassword() {
        didReceiveLoading?(true)
        NetworkClient.shared.request(api: .changePassword(changePasswordRequestModel), modelType: GenericSuccessResponseModel.self) { [weak self] result in
            guard let self = self else { return }
            didReceiveLoading?(false)
            switch result {
            case .success:
                didReceiveSuccess?()
            case .failure(let error):
                if case .validation(let errors) = error {
                    didReceiveValidationError?(error.description, errors.count > 1)
                } else {
                    didReceiveError?(error.description)
                }
            }
        }
    }
}
