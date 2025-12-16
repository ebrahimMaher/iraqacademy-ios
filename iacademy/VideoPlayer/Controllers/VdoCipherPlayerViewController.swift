//
//  VdoCipherPlayerViewController.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import UIKit
import AVKit
import VdoFramework

class VdoCipherPlayerViewController: UIViewController, PlayerViewController {
    
    
    private var vdoPlayerVC: VdoPlayerViewController?
    private var vdoAsset: VdoAsset?
    
    var videoID: String
    var otp: String
    var playbackInfo: String
    
    init(videoID: String, otp: String, playbackInfo: String) {
        self.videoID = videoID
        self.otp = otp
        self.playbackInfo = playbackInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        VdoAsset.createAsset(videoId: videoID) { [weak self] asset, error in
            guard let self = self else { return }
            if let error = error {
                print("Vdo error \(error.localizedDescription)")
                self.dismiss(animated: true)
                return
            }

            guard let asset = asset else { return }
            self.vdoAsset = asset

            DispatchQueue.main.async {
                let playerVC = VdoCipher.getVdoPlayerViewController()
                VdoCipher.setUIPlayerDelegate(self)
                VdoCipher.setPlaybackDelegate(delegate: self)
                self.vdoPlayerVC = playerVC
                asset.playOnline(otp: self.otp, playbackInfo: self.playbackInfo)
                self.present(playerVC, animated: true) {
                    UIApplication.appDelegate.addFloatingWatermark()
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.appDelegate.removeWatermark()
    }
    
}
extension VdoCipherPlayerViewController: VdoPlayerViewControllerDelegate {
    
    func didClosePlayer(controller: UIViewController) {
        controller.dismiss(animated: false)
        playerDidDismiss()
        dismiss(animated: false)
    }
    
}

extension VdoCipherPlayerViewController: AssetPlaybackDelegate {
    
    func streamPlaybackManager(playerReadyToPlay player: AVPlayer) {
        playerDidAppear()
        player.play()
    }
    
    func streamPlaybackManager(playerCurrentItemDidChange player: AVPlayer) {
        
    }
    
    func streamLoadError(error: VdoFramework.VdoError) {
        self.dismiss(animated: true)
    }
    
    
}
