//
//  HomeResponseModel.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation

struct HomeResponseModel: Codable {
    let welcomeMsg: String?
    let showJoin: Bool?
    let teachers: [HomeTeacherModel]?
    let courses: [HomeCourseModel]?
    var banners: [HomeBannerModel]?
}

struct HomeCourseModel: Codable {
    @StringOrInt var id: String?
    let name: String?
    let videos: [HomeCourseVideoModel]?
}

struct HomeCourseVideoModel: Codable {
    @StringOrInt var id: String?
    let name, url: String?
}

struct HomeTeacherModel: Codable {
    @StringOrInt var id: String?
    let coursesCount: Int?
    let name: String?
    let avatar: String?

    enum CodingKeys: String, CodingKey {
        case coursesCount = "courses_count"
        case id, name, avatar
    }
}

struct HomeBannerModel: Codable {
    @StringOrInt var id: String?
    let url: String?
    let link: String?
}
