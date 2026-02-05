//
//  NetworkError.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation

enum NetworkError: Error, Equatable {
    case noInternet
    case notAuthorized
    case wrongCredentials
    case invalidData
    case unkown
    case timeOut
    case emptyData
    case validationUnknown
    case validation(errors: [String:[String]])
    case userSuspended
    case customError(description: String, code: Int)
    case passwordReset_UserNotFound
    case passwordReset_InvalidCode
    case passwordReset_TooManyAttempts(mins: Int)
    case passwordReset_TokenExpired
    case pinningFailed
    
    var description: String {
        switch self {
        case .noInternet:
            return "يرجي التحقق من اتصالك بالانترنت"
        case .notAuthorized:
            return "انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى"
        case .wrongCredentials:
            return "بيانات تسجيل الدخول غير صحيحة. يرجى المحاولة مرة أخرى."
        case .invalidData:
            return "بيانات غير صالحة"
        case .unkown:
            return "حدث خطأ ما، يرجى المحاولة مرة أخرى لاحقًا"
        case .timeOut:
            return "تم إيقاف الطلب، يرجى المحاولة مرة أخرى لاحقًا"
        case .emptyData:
            return "لم يتم استرجاع أي بيانات، يرجى المحاولة مرة أخرى لاحقًا"
        case .validationUnknown:
            return "البيانات المقدمة غير صالحة"
        case .validation(let errors):
            var finalString = ""
            if errors.count > 1 { finalString = "\n" }
            let allErrorMessages: [String] = errors.flatMap { $0.value }
            for (index,error) in allErrorMessages.enumerated() {
                if index != 0 { finalString.append("\n") }
                finalString.append("- \(error)")
            }
            if errors.count > 1 { finalString.append("\n") }
            return finalString
        case .userSuspended:
            return "لقد تجاوزت عدد الأجهزة المسموح به"
        case .customError(let description, _):
            return description
        case .passwordReset_UserNotFound:
            return "المستخدم غير موجود."
        case .passwordReset_InvalidCode:
            return "رمز التحقق غير صالح."
        case .passwordReset_TooManyAttempts(let mins):
            return "عدد كبير جدًا من المحاولات. الرجاء المحاولة مرة أخرى بعد \(mins) دقيقة."
        case .passwordReset_TokenExpired:
            return "انتهت صلاحية رمز التحقق. الرجاء المحاولة مرة أخرى"
        case .pinningFailed:
            return "فشل التحقق من أمان الاتصال. يُرجى التحقق من اتصالك والمحاولة مرة أخرى"
        }
    }
}
