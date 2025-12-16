//
//  VerificationStatusResponseModel.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation

struct VerificationStatusResponseModel: Codable {
    let status, rejectionReason: String?
    
    var isInReview: Bool {
        status == "in_review"
    }
    
    var isVerified: Bool {
        status == "verified"
    }
    
    var isNotVerified: Bool {
        status == "not_verified"
    }
    
    var rejected: Bool {
        status == "rejected"
    }

    enum CodingKeys: String, CodingKey {
        case status
        case rejectionReason = "rejection_reason"
    }
}

struct UploadVerificationResponseModel: Codable {
    let status: String?
}
