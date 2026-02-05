//
//  HTTPTask.swift
//  iacademy
//
//  Created by Marwan Osama on 23/01/2026.
//

import Foundation

enum HTTPTask {
    case requestPlain
    case requestParameters([String : Any])
    case requestMultipart(MultipartFormData)
}
