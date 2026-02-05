//
//  ReportViolationUseCase.swift
//  iacademy
//
//  Created by Marwan Osama on 24/01/2026.
//

import Foundation

protocol ReportViolationUseCase {
    
    func execute(_ request: ReportViolationRequestModel) async throws -> ReportViolationResponseModel
}

final class ReportViolationUseCaseImpl: ReportViolationUseCase {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient = URLSessionNetworkClient.init()) {
        self.networkClient = networkClient
    }
    
    func execute(_ request: ReportViolationRequestModel) async throws -> ReportViolationResponseModel {
        return try await networkClient.request(AppAPI.reportViolation(request))
    }
}
