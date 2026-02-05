//
//  LoginUseCase.swift
//  iacademy
//
//  Created by Marwan Osama on 21/01/2026.
//

import Foundation

protocol LoginUseCase {
    func execute(request: LoginRequestModel) async throws -> LoginResponseModel
}


final class LoginUseCaseImpl: LoginUseCase {

    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient = URLSessionNetworkClient()) {
        self.networkClient = networkClient
    }

    func execute(request: LoginRequestModel) async throws -> LoginResponseModel {
        var request = request
        refreshLoginRequestModelUUID(model: &request)

        return try await networkClient.request(AuthAPI.login(request))
    }
    
    func refreshLoginRequestModelUUID(model: inout LoginRequestModel) {
        model.refreshUUID()
    }
}

