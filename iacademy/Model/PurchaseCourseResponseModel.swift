//
//  PurchaseCourseResponseModel.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation

struct PurchaseCourseResponseModel: Codable {
    let data: PurchaseCourseModel?
}

struct PurchaseCourseModel: Codable {
    @StringOrInt var id: String?
    let name, imageURL: String?
    let featured, purchased, free: Bool?
    let teacher: PurchaseCourseTeacher?
    let lectures: [PurchaseCourseLecture]?
    var collections: [CourseCollectionModel]?

    enum CodingKeys: String, CodingKey {
        case id, name
        case imageURL = "image_url"
        case featured, teacher, free, purchased
        case lectures, collections
    }
}

struct PurchaseCourseTeacher: Codable {
    @StringOrInt var id: String?
    let name, avatar: String?
}

struct PurchaseCourseLecture: Codable {
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
    
    func mapTo() -> TeacherCourseResponseModel.Lecture {
        return TeacherCourseResponseModel.Lecture.init(id: self.id, imageURL: self.imageURL, name: self.name, videosCount: self.videosCount)
    }
}
