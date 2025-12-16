//
//  RegisterViewModel.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import Foundation

class RegisterViewModel {
    
    var didReceiveValidationError: ((_ error: String,_ isMoreThanOneError: Bool) -> ())?
    var didReceiveError: ((String) -> ())?
    var didReceiveLoading: ((Bool) -> ())?
    var didReceiveRegisterResponse: ((RegisterResponseModel) -> ())?
    
    
    var registerRequestModel: RegisterRequestModel = .init()
    
    
    func register() {
//        guard validate() else { return }
        registerRequestModel.refreshUUID()
        didReceiveLoading?(true)
        NetworkClient.shared.request(api: .register(registerRequestModel), modelType: RegisterResponseModel.self) { [weak self] result in
            guard let self = self else { return }
            didReceiveLoading?(false)
            switch result {
            case .success(let registerResponseModel):
                didReceiveRegisterResponse?(registerResponseModel)
            case .failure(let error):
                if case .validation(let errors) = error {
                    didReceiveValidationError?(error.description, errors.count > 1)
                } else {
                    didReceiveError?(error.description)
                }
            }
        }
    }
    
    private func validate() -> Bool {
        let email = registerRequestModel.email
        if !email.isEmpty, !email.isValidEmail() {
            didReceiveError?("صيغة البريد الإلكتروني غير صحيحة")
            return false
        }
        
        let password = registerRequestModel.password
        if !password.isEmpty, password.count < 6 {
            didReceiveError?("يجب أن تتكون كلمة المرور من ٦ إلى ٢٥٥ حرفًا")
            return false
        }
        
        if !password.isEmpty, password.count > 255 {
            didReceiveError?("يجب أن تتكون كلمة المرور من 6 إلى 255 حرفًا")
            return false
        }
        
        return true
    }
    
    
    
}
