//
//  AppInfoUseCase.swift
//  iacademy
//
//  Created by Marwan Osama on 24/01/2026.
//

import Foundation

protocol AppInfoUseCase {
    
    func execute() async throws -> AppInfoModel
}

final class AppInfoUseCaseImpl: AppInfoUseCase {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient = URLSessionNetworkClient.init()) {
        self.networkClient = networkClient
    }
    
    func execute() async throws -> AppInfoModel {
        return try await networkClient.request(AppAPI.appInfo)
    }
    
}
