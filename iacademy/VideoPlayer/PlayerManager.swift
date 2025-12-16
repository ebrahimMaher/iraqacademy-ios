//
//  PlayerManager.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import UIKit
import AVKit
import VdoFramework

class PlayerManager {
    
    static func initiatePlayerViewController(for type: VideoType) {
        switch type {
        case .standard(let url):
            AppCoordinator.shared.present(to: .standardPlayer(url: url))
        case .adaptive(let qualities):
            AppCoordinator.shared.present(to: .adaptivePlayer(qualities: qualities))
        case .vdoCipher(let videoID, let otp, let playbackInfo):
            AppCoordinator.shared.present(to: .vdoCipherPlayer(videoID: videoID, otp: otp, playbackInfo: playbackInfo))
        case .drm(let videoURL, let licenseURL, let certificateURL):
            AppCoordinator.shared.present(to: .drmPlayer(videoURL: videoURL, licenseURL: licenseURL, certificateURL: certificateURL))
        }
    }
    
}

protocol PlayerViewController: AnyObject {
    
    func playerDidAppear()
    func playerDidDismiss()
}

extension PlayerViewController {
    
    func playerDidAppear() {
        UIApplication.appDelegate.addFloatingWatermark()
    }
    
    func playerDidDismiss() {
        UIApplication.appDelegate.removeWatermark()
    }
}


protocol QualitySwitchableController: AnyObject {
    func switchQuality(to url: String)
}
