//
//  NetworkClient.swift
//  iacademy
//
//  Created by Marwan Osama on 23/01/2026.
//

import Foundation


protocol NetworkClient {
    
    func request<T: Codable>(_ endpoint: Endpoint) async throws -> T
    
}


final class URLSessionNetworkClient: NetworkClient {
    
    private let session: URLSession
    private let interceptor: NetworkInterceptor?
    
    init(configuration: URLSessionConfiguration = SessionConfiguration.default(),
         interceptor: NetworkInterceptor = DefaultNetworkInterceptor()) {
//        let pinnedCertificates: [String] = [SSLConfiguration.shared.currentPin]
        let pinnedCertificates: [String] = []
        let delegate = pinnedCertificates.isEmpty ? nil : SSLPinningDelegate(certNames: pinnedCertificates)
        self.session = URLSession(
            configuration: configuration,
            delegate: delegate,
            delegateQueue: nil
        )
        self.interceptor = interceptor
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        
        let reachability = try? Reachability()
        if reachability?.connection == .unavailable {
            throw NetworkError.noInternet
        }
        
        var attempt = 0
        
        while true {
            do {
                
                var request = URLRequest(
                    url: endpoint.baseURL.appendingPathComponent(endpoint.path)
                )
                
                request.httpMethod = endpoint.method.rawValue
                request.allHTTPHeaderFields = endpoint.headers
                
                switch endpoint.task {
                case .requestPlain:
                    break
                    
                case .requestParameters(let params):
                    request.httpBody = try JSONSerialization.data(withJSONObject: params)
                    
                case .requestMultipart(let multipart):
                    request.setValue(multipart.contentType, forHTTPHeaderField: "Content-Type")
                    request.httpBody = multipart.body
                }
                
                if let interceptor {
                    request = try await interceptor.adapt(request, for: endpoint)
                }
                
                let (data, response) = try await session.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.timeOut
                }
                
                let statusCode = httpResponse.statusCode
                
                if 200..<300 ~= statusCode {
                    guard !data.isEmpty else {
                        throw NetworkError.emptyData
                    }
                    do {
                        return try JSONDecoder().decode(T.self, from: data)
                    } catch {
                        if T.self == String.self, let string = String(data: data, encoding: .utf8) as? T {
                            return string
                        }
                        throw NetworkError.invalidData
                    }
                }
                
                throw mapError(statusCode: statusCode, data: data, endpoint: endpoint)
                
            } catch let error as NetworkError {
                
                if let interceptor,
                   try await interceptor.retry(URLRequest(url: endpoint.baseURL),
                                               for: endpoint,
                                               dueTo: error,
                                               attempt: attempt
                   ) {
                    attempt += 1
                    continue
                }
                
                throw error
                
            } catch let error as URLError where error.code == .timedOut {
                throw NetworkError.timeOut
                
            } catch {
                if let delegate = session.delegate as? SSLPinningDelegate,
                   delegate.pinningError == .failed {
                    throw NetworkError.pinningFailed
                }
                throw NetworkError.unkown
            }
        }
        
    }
    
    private func mapError(statusCode: Int, data: Data, endpoint: Endpoint) -> NetworkError {
        switch statusCode {
        case 401:
            if case AuthAPI.login = endpoint {
                return .wrongCredentials
            } else {
                return .notAuthorized
            }
        case 403: return .userSuspended
        case 404: return .unkown
        case 422:
            if let serverError = try? JSONDecoder().decode(NetworkErrorModel.self, from: data),
               let errors = serverError.errors,
               !errors.isEmpty {
                return .validation(errors: errors)
            }
            return .validationUnknown
        default:
            if let serverError = try? JSONDecoder().decode(NetworkErrorModel.self, from: data),
               let message = serverError.message {
                return .customError(description: message, code: statusCode)
            }
            return .unkown
        }
    }
    
    
}
