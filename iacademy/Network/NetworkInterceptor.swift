//
//  NetworkInterceptor.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation
import Alamofire
import WebKit

class NetworkInterceptor: RequestInterceptor {

    private typealias RefreshCompletion = (_ succeeded: Bool, _ accessToken: String?) -> Void
    private typealias RequestRetryCompletion = (RetryResult) -> Void

    private let lock = NSLock()
    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    private var retryCount = 5
    private var hasLoggedOut = false


    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {



        lock.lock() ; defer { lock.unlock() }

        if request.retryCount > retryCount {
            completion(.doNotRetry)
            return
        }

        if let urlString = request.request?.url?.absoluteString,
           !urlString.contains("login"),
           request.response?.statusCode == 401 {

            self.logout()
            completion(.doNotRetry)
        } else {
            completion(.doNotRetry)
        }
    }


}

//MARK: - Helper Methods
extension NetworkInterceptor {


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
