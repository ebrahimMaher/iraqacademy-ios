//
//  MyCoursesResponseModel.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation

struct MyCoursesResponseModel: Codable {
    let data: [MyCourseModel]?
}

struct MyCourseModel: Codable {
    @StringOrInt var id: String?
    let videosCount: Int?
    let imageURL: String?
    let featured, purchased: Bool?
    let teacher: MyCoursesTeacherModel?
    let free: Bool?
    let name: String?
    let announcement: String?
    let lecturesCount: Int?
    let lectures: [MyCourseLecture]?
    var collections: [CourseCollectionModel]?
    let idVerificationNeeded: Bool?
    var isExpanded: Bool = false

    enum CodingKeys: String, CodingKey {
        case videosCount = "videos_count"
        case id
        case imageURL = "image_url"
        case featured, purchased, teacher, free, name, lectures, announcement, collections
        case lecturesCount = "lectures_count"
        case idVerificationNeeded = "id_verification_needed"
    }
}

struct MyCourseLecture: Codable {
    @StringOrInt var id: String?
    let imageURL: String?
    let name: String?
    let videosCount: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case imageURL = "image_url"
        case name
        case videosCount = "videos_count"
    }
}

struct MyCoursesTeacherModel: Codable {
    @StringOrInt var id: String?
    let name: String?
    let avatar: String?
}
