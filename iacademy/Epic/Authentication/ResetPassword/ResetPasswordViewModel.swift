//
//  ResetPasswordViewModel.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import Foundation

class ResetPasswordViewModel {
    
    var didReceiveValidationError: ((_ error: String,_ isMoreThanOneError: Bool) -> ())?
    var didReceiveError: ((String) -> ())?
    var didReceiveLoading: ((Bool) -> ())?
    var didReceiveSuccess: ((String) -> ())?

    var phoneCode: String?
    

    func resetPassword(phone: String) {
        didReceiveLoading?(true)
        NetworkClient.shared.request(api: .resetPassword(phone: phone, phoneCode: phoneCode ?? ""), modelType: ResetPasswordURLResponseModel.self) { [weak self] result in
            guard let self = self else { return }
            didReceiveLoading?(false)
            switch result {
            case .success(let success):
                if let url = success.url { didReceiveSuccess?(url) }
            case .failure(let error):
                if case .validation(let errors) = error {
                    didReceiveValidationError?(error.description, errors.count > 1)
                } else {
                    didReceiveError?(error.description)
                }
            }
        }    }
    
}
