//
//  NetworkRetryPolicy.swift
//  iacademy
//
//  Created by Marwan Osama on 23/01/2026.
//

import Foundation

protocol NetworkRetryPolicy {
    func shouldRetry(
        error: NetworkError,
        endpoint: Endpoint,
        attempt: Int
    ) async -> Bool
}


final class DefaultRetryPolicy: NetworkRetryPolicy {
    
    private let maxRetryCount = 3
    private var hasLoggedOut = false
    
    func shouldRetry(error: NetworkError,
                     endpoint: Endpoint,
                     attempt: Int) async -> Bool {
            
        guard attempt < maxRetryCount else {
            return false
        }
        
        switch error {
        case .notAuthorized:
            guard case AuthAPI.login = endpoint else {
                logout()
                return false
            }
            return false
        default:
            return false
        }
    }
}

extension DefaultRetryPolicy {


    func logout() {
        DispatchQueue.main.async {
            guard !self.hasLoggedOut else { return }
            self.hasLoggedOut = true
            CacheClient.shared.clearAll()
            AppCoordinator.shared.setRoot(to: .login)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.hasLoggedOut = false
        }
    }

}


protocol NetworkInterceptor {
    func adapt(_ request: URLRequest, for endpoint: Endpoint) async throws -> URLRequest
    func retry(
        _ request: URLRequest,
        for endpoint: Endpoint,
        dueTo error: NetworkError,
        attempt: Int
    ) async throws -> Bool
}

final class DefaultNetworkInterceptor: NetworkInterceptor {

    private let maxRetryCount = 2
    private var hasLoggedOut = false

    func adapt(_ request: URLRequest, for endpoint: Endpoint) async throws -> URLRequest {
        return request
    }

    func retry(
        _ request: URLRequest,
        for endpoint: Endpoint,
        dueTo error: NetworkError,
        attempt: Int
    ) async throws -> Bool {

        guard attempt < maxRetryCount else {
            return false
        }

        switch error {
        case .notAuthorized:
            guard case AuthAPI.login = endpoint else {
                await logout()
                return false
            }
            return false
        default:
            return false
        }
    }

    private func logout() async {
        guard !hasLoggedOut else { return }
        hasLoggedOut = true

        await MainActor.run {
            CacheClient.shared.clearAll()
            AppCoordinator.shared.setRoot(to: .login)
        }
    }
}
