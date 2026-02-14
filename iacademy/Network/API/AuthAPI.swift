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
    case telegramVerificationLink
    case forgetPassword(phone: String)
    case passwordReset(token: String, password: String)
    case logout
    
    var baseURL: URL {
        return URL(string: Environment.apiUrl)!
    }
    
    var path: String {
        switch self {
        case .login: return "login"
        case .register: return "register"
        case .logout:  return "logout"
        case .telegramVerificationLink: return "telegram/verify/url"
        case .forgetPassword: return "password/reset"
        case .passwordReset(let token, _): return "password/reset/\(token)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .register, .logout, .forgetPassword, .passwordReset: return .post
        default: return .get
        }
    }
    
    var headers: [String : String] {
        switch self {
        case .telegramVerificationLink: return DefaultHeaders.common
        default: return DefaultHeaders.withoutAuth
        }
        
    }
    
    var task: HTTPTask {
        switch self {
        case .login(let model):
            return .requestParameters(model.dictionary)
        case .register(let model):
            return .requestParameters(model.dictionary)
        case .logout:
            return .requestPlain
        case .telegramVerificationLink:
            return .requestPlain
        case .forgetPassword(let phone):
            return .requestParameters(["phone" : phone, "phone_code" : "+966"])
        case .passwordReset(_, let password):
            return .requestParameters(["password" : password])
        }
    }
    
}
