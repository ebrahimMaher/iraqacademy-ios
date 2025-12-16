//
//  TeacherCourseResponseModel.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation

struct TeacherCourseResponseModel: Codable {
    let data: [Courses]?
    let links: Links?
    let meta: Meta?
    
    struct Courses: Codable {
        @StringOrInt var id: String?
        let name: String?
        let imageURL: String?
        let featured: Bool?
        let teacher: Teacher?
        let lecturesCount, videosCount: Int?
        let free: Bool?
        let announcement: String?
        var purchased: Bool?
        var lectures: [Lecture]?
        var collections: [CourseCollectionModel]?
        let idVerificationNeeded: Bool?
        var isExpanded: Bool = false

        enum CodingKeys: String, CodingKey {
            case id, name
            case imageURL = "image_url"
            case featured, teacher, lectures, collections
            case lecturesCount = "lectures_count"
            case videosCount = "videos_count"
            case idVerificationNeeded = "id_verification_needed"
            case free, purchased, announcement
        }
    }
    
    struct Lecture: Codable {
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
    
    struct Teacher: Codable {
        @StringOrInt var id: String?
        let name: String?
        let avatar: String?
        let coursesCount: Int?

        enum CodingKeys: String, CodingKey {
            case id, name, avatar
            case coursesCount = "courses_count"
        }
    }
    
    struct Links: Codable {
        let first, last: String?
        let prev, next: String?
    }
    
    struct Meta: Codable {
        let currentPage, from, lastPage: Int?
        let path: String?
        let perPage, to, total: Int?

        enum CodingKeys: String, CodingKey {
            case currentPage = "current_page"
            case from
            case lastPage = "last_page"
            case path
            case perPage = "per_page"
            case to, total
        }
    }
}


