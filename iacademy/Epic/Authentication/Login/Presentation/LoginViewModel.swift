//
//  LoginViewModel.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import Foundation

@MainActor
class LoginViewModel {
    
    private let loginUseCase: LoginUseCase
    private var loginTask: Task<Void, Never>?
    var loginRequestModel: LoginRequestModel
    
    var didReceiveValidationError: ((_ error: String,_ isMoreThanOneError: Bool) -> ())?
    var didReceiveError: ((String) -> ())?
    var didReceiveLoading: ((Bool) -> ())?
    var didReceiveLoginResponse: ((LoginResponseModel) -> ())?
    
    init(loginUseCase: LoginUseCase = LoginUseCaseImpl()) {
        self.loginUseCase = loginUseCase
        self.loginRequestModel = .init()
        self.loginTask = nil
    }
    
    func login() {
        loginTask?.cancel()
        loginTask = Task {
            didReceiveLoading?(true)
            defer { didReceiveLoading?(false) }
            do {
                let response = try await loginUseCase.execute(request: loginRequestModel)
                didReceiveLoginResponse?(response)
            } catch {
                handleLoginError(error)
            }
        }
    }

    func cancelLogin() {
        loginTask?.cancel()
    }
    
    
}

//MARK: - error handling
extension LoginViewModel {
    
    private func handleLoginError(_ error: Error) {
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
