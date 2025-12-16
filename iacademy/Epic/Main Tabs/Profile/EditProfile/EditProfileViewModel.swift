//
//  EditProfileViewModel.swift
//  iacademy
//
//  Created by Marwan Osama on 15/12/2025.
//

import Foundation

class EditProfileViewModel {
    
    var editProfileRequestModel: EditProfileRequestModel = .init()
    
    var didReceiveValidationError: ((_ error: String,_ isMoreThanOneError: Bool) -> ())?
    var didReceiveError: ((String) -> ())?
    var didReceiveLoading: ((Bool) -> ())?
    var didUploadImageSuccess: ((ProfileResponseModel) -> ())?
    var didUpdateProfileSuccess: ((ProfileResponseModel) -> ())?
    
    var isFormValid: Bool {
        guard let originalUser = CacheClient.shared.userModel else { return false }
        
        let name = editProfileRequestModel.name
        let email = editProfileRequestModel.email
        
        let nameChanged = name != originalUser.name
        let emailChanged = email != originalUser.email

        return !name.isEmpty &&
               !email.isEmpty && email.isValidEmail() &&
               (nameChanged || emailChanged)
    }
    
    func setInputs(name: String, email: String) {
        editProfileRequestModel.name = name
        editProfileRequestModel.email = email
    }

    func uploadAvatarImage(_ data: Data, _ mimeType: String, _ fileName: String) {
        didReceiveLoading?(true)
        NetworkClient.shared.request(api: .editAvatar(imageData: data, mime: mimeType, file: fileName), modelType: ProfileResponseModel.self) { [weak self] result in
            guard let self = self else { return }
            didReceiveLoading?(false)
            switch result {
            case .success(let profileResponseModel):
                didUploadImageSuccess?(profileResponseModel)
            case .failure(let error):
                didReceiveError?(error.description)
            }
        }
    }

    func saveProfile() {
        didReceiveLoading?(true)
        NetworkClient.shared.request(api: .editProfile(editProfileRequestModel), modelType: ProfileResponseModel.self) { [weak self] result in
            guard let self = self else { return }
            didReceiveLoading?(false)
            switch result {
            case .success(let profileResponseModel):
                didUpdateProfileSuccess?(profileResponseModel)
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
