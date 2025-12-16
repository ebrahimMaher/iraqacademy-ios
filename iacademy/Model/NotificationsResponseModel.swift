//
//  NotificationsResponseModel.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation

struct NotificationsResponseModel: Codable {
    let data: [Notifications]?
    let links: Links?
    let meta: Meta?
    
    struct Notifications: Codable {
        let unread: Bool?
        let content, color, id, created_at, title, type, icon: String?
        let created_at_timestamp: Double?
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
