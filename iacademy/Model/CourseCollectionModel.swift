//
//  CourseCollectionModel.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation

struct CourseCollectionModel: Codable {
    @StringOrInt var id: String?
    let name: String?
    let lecturesCount: Int?
    var isExpanded: Bool = false
    var lectures: [CourseCollectionContent.Lecture] = []

    enum CodingKeys: String, CodingKey {
        case id, name
        case lecturesCount = "lectures_count"
    }
}

struct CourseCollectionContent: Codable {
    let lectures: [Lecture]?
    
    
    struct Lecture: Codable {
        @StringOrInt var id: String?
        let name: String?
        let videosCount: Int?
        
        enum CodingKeys: String, CodingKey {
            case id, name
            case videosCount = "videos_count"
        }
    }
}
