//
//  SetNewPasswordUseCase.swift
//  iacademy
//
//  Created by Marwan Osama on 14/02/2026.
//

import Foundation

protocol SetNewPasswordUseCase {
    func execute(token: String, password: String) async throws -> SetNewPasswordResponseModel
}

class SetNewPasswordUseCaseImpl: SetNewPasswordUseCase {
    
    let networkClient: NetworkClient
    
    init(networkClient: NetworkClient = URLSessionNetworkClient.init()) {
        self.networkClient = networkClient
    }
    
    func execute(token: String, password: String) async throws -> SetNewPasswordResponseModel {
        return try await networkClient.request(AuthAPI.passwordReset(token: token, password: password))
    }
}
