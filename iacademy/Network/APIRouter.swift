//
//  APIRouter.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation
import Alamofire


protocol APIConfigurationProtocol: URLRequestConvertible {
    var parameters: Parameters { get }
    var headers: HTTPHeaders { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var baseURL: String { get }
    
    func asURLRequest() throws -> URLRequest
}

enum APIRouter: APIConfigurationProtocol {
    
    case none
    case appInfo
    case login(_ loginRequestModel: LoginRequestModel)
    case logout
    case deleteAccount(reason: String)
    case register(_ registerRequestModel: RegisterRequestModel)
    case telegramVerificationLink
    case homeData
    case purchaseCourse(code: String)
    case purchaseSpecificCourse(courseID: String, code: String)
    case purchaseFreeCourse(courseID: String)
    case myCourses
    case courseDetails(id: Int)
    case lectureDetails(id: String)
    case courseCollectionContent(collectionID: String)
    case lectureVideoLink(id: String)
    case teacherCourses(id: String, page: Int)
    case notifications
    case profile
    case editProfile(_ editProfileRequestModel: EditProfileRequestModel)
    case editAvatar(imageData: Data, mime: String, file: String)
    case changePassword(_ changePasswordRequestModel: ChangePasswordRequestModel)
    case resetPassword(phone: String, phoneCode: String)
    case passwordResetWithToken(token: String, password: String)
    case verificationStatus
    case statusIDVerification
    case uploadIDVerification(idFront: Data, idBack: Data, residenceCard: Data, idNumber: String?)

    case reportViolation(_ reportRequestModel: ReportViolationRequestModel)
    
    var baseURL: String {
        return Environment.apiUrl
    }
    
    var path: String {
        switch self {
        case .appInfo: return "app"
        case .login: return "login"
        case .logout: return "logout"
        case .deleteAccount: return "account/delete"
        case .register: return "register"
        case .telegramVerificationLink: return "telegram/verify/url"
        case .homeData: return "home"
        case .purchaseCourse: return "courses/purchase"
        case .purchaseSpecificCourse(let courseID, _): return "courses/\(courseID)/purchase"
        case .purchaseFreeCourse(let courseID): return "courses/\(courseID)/purchase"
        case .myCourses: return "courses/my-courses"
        case .courseDetails(let id): return "courses/\(id)"
        case .lectureDetails(let id): return "lectures/\(id)"
        case .courseCollectionContent(let id): return "collections/\(id)"
        case .lectureVideoLink(let id): return "analytics/\(id)"
        case .teacherCourses(let id, _): return "teachers/\(id)/courses"
        case .notifications: return "notifications"
        case .profile, .editProfile: return "profile"
        case .editAvatar: return "profile/avatar"
        case .changePassword: return "profile/password"
        case .resetPassword: return "password/reset"
        case .passwordResetWithToken(let token, _): return "password/reset/\(token)"
        case .statusIDVerification: return "id-verification/status"
        case .uploadIDVerification: return "id-verification"
        case .reportViolation: return "violations"
        default: return ""
        }
    }
    
    var parameters: Parameters {
        switch self {
            
        case .login(let model): return model.dictionary
        case .deleteAccount(let reason): return ["reason" : reason]
        case .register(let model): return model.dictionary
        case .purchaseCourse(let code): return ["code" : code]
        case .purchaseSpecificCourse(_, let code): return ["code" : code]
        case .teacherCourses(_, let page): return ["page": page]
        case .editProfile(let model): return model.dictionary
        case .changePassword(let model): return model.dictionary
        case .passwordResetWithToken(_, let password): return ["password" : password]
        case .resetPassword(let phone, let phoneCode): return ["phone" : phone, "phone_code" : phoneCode]
        case .reportViolation(let model): return model.dictionary
        default: return [:]
            
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login: return .post
        case .deleteAccount: return .post
        case .register: return .post
        case .logout: return .post
        case .resetPassword, .passwordResetWithToken: return .post
        case .purchaseCourse, .purchaseSpecificCourse, .purchaseFreeCourse: return .post
        case .changePassword: return .post
        case .editProfile: return .put
        case .editAvatar: return .post
        case .uploadIDVerification: return .post
        case .reportViolation: return .post
        default: return .get
        }
    }
    
   
    var headers: HTTPHeaders {
        var headers: HTTPHeaders = [
            .init(name: "Accept", value: "application/json"),
            .init(name: "Content-Type", value: "application/json"),
            .init(name: "App-Platform", value: "ios"),
            .init(name: "X-Analytics-ID", value: KeyManager.getAPIKey() ?? ""),
            .init(name: "App-Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"),
            .init(name: "Authorization", value: "Bearer \(CacheClient.shared.authToken)"),
        ]
        switch self {
        case .appInfo, .login, .register, .resetPassword, .passwordResetWithToken:
            headers.remove(name: "Authorization")
            return headers
            
        default: return headers
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let urlString = baseURL + path
        let url = try urlString.asURL()
        var urlRequest = URLRequest(url: url)
        urlRequest.method = method
        urlRequest.headers = headers

        switch self {
        case .editAvatar(let data, let mime, let file):
            let boundary = "Boundary-\(UUID().uuidString)"
            urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = createMultipartBody(data: data, mime: mime, file: file, boundary: boundary)
            return urlRequest
            
        case .uploadIDVerification(let idFront, let idBack, let residenceCard, let idNumber):
            let boundary = "Boundary-\(UUID().uuidString)"
            urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = createIDVerificationMultipartBody(
                idFront: idFront,
                idBack: idBack,
                residenceCard: residenceCard,
                idNumber: idNumber,
                boundary: boundary
            )
            return urlRequest

        default:
            switch method {
            case .get, .delete:
                return try URLEncoding.default.encode(urlRequest, with: parameters)
            default:
                return try JSONEncoding.default.encode(urlRequest, with: parameters)
            }
        }
    }
    
    private func createMultipartBody(data: Data, mime:String, file:String, boundary: String) -> Data {
        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"avatar\"; filename=\"\(file)\"\r\n")
        body.append("Content-Type: \(mime)\r\n\r\n")
        body.append(data)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")
        return body
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

extension APIRouter {
    
    private func createIDVerificationMultipartBody(idFront: Data, idBack: Data, residenceCard: Data, idNumber: String?, boundary: String) -> Data {
        var body = Data()
        
        let images: [(String, Data)] = [
            ("id_front", idFront),
            ("id_back", idBack),
            ("residence_card", residenceCard)
        ]
        
        for (name, data) in images {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(name).jpg\"\r\n")
            body.append("Content-Type: image/jpeg\r\n\r\n")
            body.append(data)
            body.append("\r\n")
        }
        
        if let idNumber = idNumber {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"id_number\"\r\n\r\n")
            body.append(idNumber)
            body.append("\r\n")
        }

        body.append("--\(boundary)--\r\n")
        return body
    }
}
