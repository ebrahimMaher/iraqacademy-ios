//
//  IDVerificationViewModel.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import UIKit

class IDVerificationViewModel {
    
    var didReceiveValidationError: ((_ error: String,_ isMoreThanOneError: Bool) -> ())?
    var didReceiveError: ((String) -> ())?
    var didReceiveLoading: ((Bool) -> ())?
    var didReceiveStatus: ((VerificationStatusResponseModel) -> ())?
    var didReceiveVerificationSuccess: (() -> ())?
        
    var frontImage: UIImage?
    var backImage: UIImage?
    var resImage: UIImage?
    var nationalID: String?
    
    var verifyButtonEnabled: Bool {
        return (frontImage != nil) && (backImage != nil) && (resImage != nil)
    }
    
    func fetchVerificationStatus() {
        didReceiveLoading?(true)
        NetworkClient.shared.request(api: .statusIDVerification, modelType: VerificationStatusResponseModel.self) { [weak self] result in
            guard let self = self else { return }
            didReceiveLoading?(false)
            switch result {
            case .success(let response):
                didReceiveStatus?(response)
            case .failure(let error):
                didReceiveError?(error.description)
            }
        }
    }

    func verifyID() {
        guard let idFront = frontImage?.jpegData(compressionQuality: 0.8),
              let idBack = backImage?.jpegData(compressionQuality: 0.8),
              let residenceCard = resImage?.jpegData(compressionQuality: 0.8) else { return }
        didReceiveLoading?(true)
        NetworkClient.shared.request(api: .uploadIDVerification(idFront: idFront, idBack: idBack, residenceCard: residenceCard, idNumber: nationalID), modelType: UploadVerificationResponseModel.self) { [weak self] result in
            guard let self = self else { return }
            didReceiveLoading?(false)
            switch result {
            case .success:
                didReceiveVerificationSuccess?()
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
