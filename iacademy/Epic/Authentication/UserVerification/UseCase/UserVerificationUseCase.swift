//
//  UserVerificationUseCase.swift
//  iacademy
//
//  Created by Marwan Osama on 11/02/2026.
//

import Foundation

protocol UserVerificationUseCase {
    func execute() async throws -> TelegramVerificationLink
}

final class UserVerificationUseCaseImpl: UserVerificationUseCase {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient = URLSessionNetworkClient.init()) {
        self.networkClient = networkClient
    }
    
    func execute() async throws -> TelegramVerificationLink {
        return try await networkClient.request(AuthAPI.telegramVerificationLink)
    }
}
