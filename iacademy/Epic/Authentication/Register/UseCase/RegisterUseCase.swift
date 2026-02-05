//
//  RegisterUseCase.swift
//  iacademy
//
//  Created by Marwan Osama on 24/01/2026.
//

import Foundation

protocol RegisterUseCase {
    
    func execute(_ request: RegisterRequestModel) async throws -> RegisterResponseModel
}

final class RegisterUseCaseImpl: RegisterUseCase {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient = URLSessionNetworkClient.init()) {
        self.networkClient = networkClient
    }
    
    func execute(_ request: RegisterRequestModel) async throws -> RegisterResponseModel {
        var request = request
        refreshUUID(&request)
        return try await networkClient.request(AuthAPI.register(request))
    }
    
    private func refreshUUID(_ model: inout RegisterRequestModel) {
        model.refreshUUID()
    }
}
