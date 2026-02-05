//
//  AuthAPI.swift
//  iacademy
//
//  Created by Marwan Osama on 23/01/2026.
//

import Foundation

enum AuthAPI: Endpoint {
    
    case login(_ loginRequestModel: LoginRequestModel)
    case register(_ registerRequestModel: RegisterRequestModel)
    case logout
    
    var baseURL: URL {
        return URL(string: Environment.apiUrl)!
    }
    
    var path: String {
        switch self {
        case .login:
            return "login"
        case .register:
            return "register"
        case .logout:
            return "logout"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .register, .logout: return .post
        }
    }
    
    var headers: [String : String] {
        return DefaultHeaders.withoutAuth
    }
    
    var task: HTTPTask {
        switch self {
        case .login(let model):
            return .requestParameters(model.dictionary)
        case .register(let model):
            return .requestParameters(model.dictionary)
        case .logout:
            return .requestPlain
        }
    }
    
}
