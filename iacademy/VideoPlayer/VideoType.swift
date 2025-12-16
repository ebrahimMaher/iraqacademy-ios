//
//  VideoType.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import Foundation

enum VideoType {
    case standard(String) // URL
    case adaptive([(String , String)]) // [quality -> URL]
    case vdoCipher(videoID: String, otp: String, playbackInfo: String)
    case drm(videoURL: String, licenseURL: String, certificateURL: String)
}
