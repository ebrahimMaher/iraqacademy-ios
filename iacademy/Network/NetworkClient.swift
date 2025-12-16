//
//  NetworkClient.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation
import Alamofire

class NetworkClient {
    
    static let shared = NetworkClient()

    private let session: Session!
    private init(session: Session = .default) {
        let evaluators = [
            SSLConfiguration.shared.currentPin: PinnedCertificatesTrustEvaluator()
        ]
//        self.session = Session(serverTrustManager: ServerTrustManager(evaluators: evaluators))
        self.session = .default
    }

    func request<T: Codable>(api: APIRouter, modelType: T.Type, completion: @escaping ((Result<T,NetworkError>) -> Void)) {
        
        let reachability = try? Reachability()
        if reachability?.connection == .unavailable {
            completion(.failure(.noInternet))
            return
        }
        session.request(api, interceptor: NetworkInterceptor())
            .validate(statusCode: 200..<300)
            .responseData { response in
                
                if let error = response.error {
                    if let afError = error.asAFError,
                       case let .serverTrustEvaluationFailed(reason) = afError {
                        completion(.failure(.pinningFailed))
                        return
                    }
                }
            
                guard let statusCode = (response.response?.statusCode) else {
                    completion(.failure(.timeOut))
                    return
                }
                
                switch response.result {
                case .success(let data):
                    
                    guard !data.isEmpty else {
                        completion(.failure(.emptyData))
                        return
                    }
                    do {
                        let obj = try JSONDecoder().decode(T.self, from: data)
                        completion(.success(obj))
                    } catch {
                        if let stringResponse = String(data: data, encoding: .utf8) {
                            print("Received plain string: \(stringResponse)")
                            if let result = stringResponse as? T {
                                completion(.success(result))
                                return
                            }
                        }
                        print("Decoding Error \(error)")
                        completion(.failure(.invalidData))
                    }
                case .failure(let error):
                    switch statusCode {
                    case 401:
                        if case .login = api {
                            completion(.failure(.wrongCredentials))
                        } else {
                            completion(.failure(.notAuthorized))
                        }
                    case 403:
                        completion(.failure(.userSuspended))
                    case 404:
                        if case .passwordResetWithToken = api {
                            completion(.failure(.passwordReset_TokenExpired))
                        }
                    case 422:
                        if let data = response.data,
                           let serverError = try? JSONDecoder().decode(NetworkErrorModel.self, from: data), let validationErrors = serverError.errors, !validationErrors.isEmpty {
                            completion(.failure(.validation(errors: validationErrors)))
                        } else {
                            completion(.failure(.validationUnknown))
                        }
                    default:
                        if let data = response.data,
                           let serverError = try? JSONDecoder().decode(NetworkErrorModel.self, from: data), let message = serverError.message {
                            completion(.failure(.customError(description: message, code: statusCode)))
                        } else {
                            completion(.failure(.unkown))
                        }
                    }
                }
            }
    }
}
