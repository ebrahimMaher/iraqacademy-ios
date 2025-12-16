//
//  LoginViewModel.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import Foundation

class LoginViewModel {
    
    
    var loginRequestModel: LoginRequestModel = .init()
    
    var didReceiveValidationError: ((_ error: String,_ isMoreThanOneError: Bool) -> ())?
    var didReceiveError: ((String) -> ())?
    var didReceiveLoading: ((Bool) -> ())?
    var didReceiveLoginResponse: ((LoginResponseModel) -> ())?
    
    func login() {
        loginRequestModel.refreshUUID()
        didReceiveLoading?(true)
        NetworkClient.shared.request(api: .login(loginRequestModel), modelType: LoginResponseModel.self) { [weak self] result in
            guard let self = self else { return }
            didReceiveLoading?(false)
            switch result {
            case .success(let loginResponseModel):
                didReceiveLoginResponse?(loginResponseModel)
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
