//
//  ProfileViewModel.swift
//  iacademy
//
//  Created by Marwan Osama on 15/12/2025.
//

import Foundation

class ProfileViewModel {
    var didReceiveError: ((String) -> ())?
    var didReceiveLoading: ((Bool) -> ())?
    var didReceiveProfileResponse: ((ProfileResponseModel) -> ())?
    
    func fetchMyProfile() {
        didReceiveLoading?(true)
        NetworkClient.shared.request(api: .profile, modelType: ProfileResponseModel.self) { [weak self] result in
            guard let self = self else { return }
            didReceiveLoading?(false)
            switch result {
            case .success(let profileResponseModel):
                didReceiveProfileResponse?(profileResponseModel)
            case .failure(let error):
                didReceiveError?(error.description)
            }
        }
    }
}
