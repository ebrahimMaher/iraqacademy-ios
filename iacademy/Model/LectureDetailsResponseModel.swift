//
//  LectureDetailsResponseModel.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation

struct LectureDetailsResponseModel: Codable {
    let videos: [LectureDetailsVideo]?
}

struct LectureDetailsVideo: Codable {
    @StringOrInt var id: String?
    let name, type, createdAt: String?
    let duration: String?

    enum CodingKeys: String, CodingKey {
        case id, name, type
        case createdAt = "created_at"
        case duration
    }
}
