//
//  StandardPlayerViewController.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import AVKit
import UIKit

class StandardPlayerViewController: AVPlayerViewController, PlayerViewController {
    
    var videoURL: String
    
    init(videoURL: String) {
        self.videoURL = videoURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.landscapeLeft, .landscapeRight]
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenRecordingChanged),
            name: UIScreen.capturedDidChangeNotification,
            object: nil)

        updatesNowPlayingInfoCenter = false
        allowsPictureInPicturePlayback = false
        
        initializeVideo()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playerDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playerDidDismiss()
    }
    
    private func initializeVideo() {
        guard let url = URL(string: videoURL) else { return }
        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)
        player?.allowsExternalPlayback = false
        player?.usesExternalPlaybackWhileExternalScreenIsActive = false
        player?.play()
        screenRecordingChanged()
    }
    
    @objc private func screenRecordingChanged() {
        if UIScreen.main.isCaptured {
            self.player?.pause()
            UIApplication.appDelegate.removeWatermark()
            self.dismiss(animated: true, completion: nil)
        }
    }
}
