//
//  RegisterViewModel.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import Foundation

@MainActor
class RegisterViewModel {
    
    private let registerUseCase: RegisterUseCase
    
    var didReceiveValidationError: ((_ error: String,_ isMoreThanOneError: Bool) -> ())?
    var didReceiveError: ((String) -> ())?
    var didReceiveLoading: ((Bool) -> ())?
    var didReceiveRegisterResponse: ((RegisterResponseModel) -> ())?
    
    
    var registerRequestModel: RegisterRequestModel = .init()
    
    init(registerUseCase: RegisterUseCase = RegisterUseCaseImpl()) {
        self.registerUseCase = registerUseCase
    }
    
    
    func register() {
        Task {
            didReceiveLoading?(true)
            defer { didReceiveLoading?(false) }
            do {
                let response = try await registerUseCase.execute(registerRequestModel)
                didReceiveRegisterResponse?(response)
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
        if case .validation(let errors) = error {
            didReceiveValidationError?(error.description, errors.count > 1)
        } else {
            didReceiveError?(error.description)
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
