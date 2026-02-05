//
//  Endpoint.swift
//  iacademy
//
//  Created by Marwan Osama on 23/01/2026.
//

import Foundation

protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var task: HTTPTask { get }
}

