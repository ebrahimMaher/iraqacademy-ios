//
//  MultipartBuilder.swift
//  iacademy
//
//  Created by Marwan Osama on 23/01/2026.
//

import Foundation

struct MultipartFormData {
    let boundary: String
    let body: Data
    let contentType: String
}

struct MultipartFormDataBuilder {
    
    static func avatar(data: Data, mime: String, fileName: String) -> MultipartFormData {
        
        let boundary = UUID().uuidString
        var body = Data()

        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"avatar\"; filename=\"\(fileName)\"\r\n")
        body.append("Content-Type: \(mime)\r\n\r\n")
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n")

        return MultipartFormData(
            boundary: boundary,
            body: body,
            contentType: "multipart/form-data; boundary=\(boundary)"
        )
    }
    
}
