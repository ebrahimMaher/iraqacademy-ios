//
//  AppAPI.swift
//  iacademy
//
//  Created by Marwan Osama on 24/01/2026.
//

import Foundation

enum AppAPI: Endpoint {
    
    case appInfo
    case reportViolation(_ request: ReportViolationRequestModel)
    
    var baseURL: URL {
        return URL(string: Environment.apiUrl)!
    }
    
    var path: String {
        switch self {
        case .appInfo: return "app"
        case .reportViolation: return "violations"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .appInfo: return .get
        case .reportViolation: return .post
        }
    }
    
    var headers: [String : String] {
        switch self {
        case .appInfo: return DefaultHeaders.withoutAuth
        case .reportViolation: return DefaultHeaders.common
        }
        
    }
    
    var task: HTTPTask {
        switch self {
        case .appInfo:
            return .requestPlain
        case .reportViolation(let requestModel):
            return .requestParameters(requestModel.dictionary)
        }
    }
    
    
}
