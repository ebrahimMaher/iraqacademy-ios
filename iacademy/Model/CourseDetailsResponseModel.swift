//
//  CourseDetailsResponseModel.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation

struct CourseDetailsResponseModel: Codable {
    let data: CourseDetailsModel?
}

struct CourseDetailsModel: Codable {
    @StringOrInt var id: String?
    let name: String?
    let imageURL: String?
    let featured: Bool?
    let teacher: CourseDetailsTeacher?
    let lecturesCount, videosCount: Int?
    let lectures: [CourseDetailsLecture]?
    let free, purchased: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name
        case imageURL = "image_url"
        case featured, teacher
        case lecturesCount = "lectures_count"
        case videosCount = "videos_count"
        case lectures, free, purchased
    }
}

// MARK: - Lecture
struct CourseDetailsLecture: Codable {
    @StringOrInt var id: String?
    let name: String?
    let imageURL: String?
    let videosCount: Int?

    enum CodingKeys: String, CodingKey {
        case id, name
        case imageURL = "image_url"
        case videosCount = "videos_count"
    }
}

// MARK: - Teacher
struct CourseDetailsTeacher: Codable {
    @StringOrInt var id: String?
    let name: String?
    let avatar: String?
    let coursesCount: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, avatar
        case coursesCount = "courses_count"
    }
}
