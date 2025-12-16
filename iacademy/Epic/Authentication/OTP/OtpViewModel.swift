//
//  OtpViewModel.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import Foundation

class OtpViewModel {
    
    var didReceiveValidationError: ((_ error: String,_ isMoreThanOneError: Bool) -> ())?
    var didReceiveError: ((String) -> ())?
    var didReceiveLoading: ((Bool) -> ())?
    var didReceiveSuccess: (() -> ())?

    func validateOTP(code: String, email: String) {
//        didReceiveLoading?(true)
//        NetworkClient.shared.request(api: .getPasswordResetToken(code: code, email: email), modelType: GetPasswordResetTokenResponseModel.self) { [weak self] result in
//            guard let self = self else { return }
//            didReceiveLoading?(false)
//            switch result {
//            case .success(let success):
//                didReceiveSuccess?()
//            case .failure(let error):
//                if case .validation(let errors) = error {
//                    didReceiveValidationError?(error.description, errors.count > 1)
//                } else {
//                    didReceiveError?(error.description)
//                }
//            }
//        }
    }
}
