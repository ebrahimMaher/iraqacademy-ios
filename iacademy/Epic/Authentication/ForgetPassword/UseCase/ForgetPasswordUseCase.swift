//
//  ForgetPasswordUseCase.swift
//  iacademy
//
//  Created by Marwan Osama on 14/02/2026.
//

import Foundation

protocol ForgetPasswordUseCase {
    func execute(phone: String) async throws -> ForgetPasswordResponseModel
}

class ForgetPasswordUseCaseImpl: ForgetPasswordUseCase {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient = URLSessionNetworkClient()) {
        self.networkClient = networkClient
    }
    
    func execute(phone: String) async throws -> ForgetPasswordResponseModel {
        return try await networkClient.request(AuthAPI.forgetPassword(phone: phone))
    }
}
