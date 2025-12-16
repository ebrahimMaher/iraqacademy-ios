//
//  LectureDetailsVC.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import UIKit
import AVKit
import VdoFramework
import AVFoundation

class LectureDetailsVC: UIViewController {

    @IBOutlet weak var navigationHeader: NavigationHeader!
    @IBOutlet weak var itemsTV: UITableView!
    
    private let loadingView = LoadingView()
    private let viewModel = LectureDetailsViewModel()
    
    var lectureID: String?
    var lectureName: String?
    var videos: [LectureDetailsVideo] = .init()
    var vdoAsset: VdoAsset?
    var vdoPlayer: AVPlayer?
    var vdoPlayerController: VdoPlayerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenRecordingChanged),
            name: UIScreen.capturedDidChangeNotification,
            object: nil)
        bind()
        setupUI()
        viewModel.fetchLectureDetails(id: lectureID)
        
        VdoCipher.setUIPlayerDelegate(self)
        VdoCipher.setPlaybackDelegate(delegate: self)

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.appDelegate.removeWatermark()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func bind() {
        viewModel.didReceiveError = { [weak self] error in
            guard let self = self else { return }
            showSimpleAlert(title: "خطأ", message: error)
        }
        
        viewModel.didReceiveLoading = { [weak self] loading in
            guard let self = self else { return }
            loadingView.isHidden = !loading
        }
        
        viewModel.didReceiveLectureDetails = { [weak self] videos in
            guard let self = self else { return }
            self.videos = videos
            self.itemsTV.reloadData()
        }
        
        viewModel.didReceiveVideoLink = { [weak self] videoLink in
            guard let self = self else { return }
            handleVideo(videoLink)
        }
    }

    private func setupUI() {
        loadingView.setup(in: view)
        
        navigationHeader.title = lectureName ?? "الفصل"
        
        itemsTV.delegate = self
        itemsTV.dataSource = self
        itemsTV.register(CourseVideoTVCell.nib, forCellReuseIdentifier: CourseVideoTVCell.identifier)
    }
    
    private func handleVideo(_ video: LectureVideoLinkModel) {
        guard let type = video.type else { return }
        if type == "mp4" {
            guard let url = video.url else { return }
            PlayerManager.initiatePlayerViewController(for: .standard(url))
        } else if type == "mp4_qualities" {
            guard let urls = video.urls, !urls.isEmpty else { return }
            let availableQualities = urls.map { ($0.quality, $0.url) }
            PlayerManager.initiatePlayerViewController(for: .adaptive(availableQualities))
        } else if type == "npd" {
            guard let videoURL = video.decryptURLDrm(), let license = video.decryptLicenseDrm(), let certificate = video.decryptCertificateDrm() else { return }
            PlayerManager.initiatePlayerViewController(for: .drm(videoURL: videoURL, licenseURL: license, certificateURL: certificate))
        } else {
            guard let otp = video.decryptOTPVdoCipher(), let playbackInfo = video.playbackInfo, let videoId = video.decryptVideoIDsVdoCipher() else { return }
//            PlayerManager.initiatePlayerViewController(for: .vdoCipher(videoID: videoId, otp: otp, playbackInfo: playbackInfo))
            initiateVdoPlayer(otp: otp, playbackInfo: playbackInfo, videoID: videoId)
        }
        
    }
    
    private func initiateVdoPlayer(otp: String, playbackInfo: String, videoID: String) {
        VdoAsset.createAsset(videoId: videoID, playerId: "mo8JOMwqnYQOGEUZ") { [weak self] asset, error in //playerId: "mo8JOMwqnYQOGEUZ"
            guard let self = self else { return }
            if let error = error {
                print("Vdo error \(error.localizedDescription)")
                showSimpleAlert(title: "خطأ", message: "عذراً، حدث خطأ أثناء تحميل الفيديو. يرجى المحاولة مرة أخرى لاحقاً.")
                return
            }
            guard let asset = asset else { return }
            self.vdoAsset = asset
            DispatchQueue.main.async {
                let playerVC = VdoCipher.getVdoPlayerViewController()
                self.vdoPlayerController = playerVC
                asset.playOnline(otp: otp, playbackInfo: playbackInfo)
                self.present(playerVC, animated: true) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        UIApplication.appDelegate.addFloatingWatermark()
                    }
                }
            }
        }
    }
    
    private func continueVideo(_ player: AVPlayer) {
        let targetTime = CMTime(seconds: 300, preferredTimescale: 1000)
        let interval: TimeInterval = 0.1
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if player.status == .readyToPlay,
               let duration = player.currentItem?.duration,
               CMTIME_IS_NUMERIC(duration),
               targetTime <= duration {
                player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero)
                timer.invalidate()
            }
        }
    }
    
    @objc private func screenRecordingChanged() {
        if UIScreen.main.isCaptured {
            UIApplication.appDelegate.removeWatermark()
            self.vdoPlayer?.pause()
            self.vdoPlayer?.replaceCurrentItem(with: nil)
            self.vdoPlayerController?.dismiss(animated: true)
        }
    }


}


extension LectureDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CourseVideoTVCell.identifier, for: indexPath) as! CourseVideoTVCell
        cell.configure(videos[indexPath.row], index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.fetchVideoLink(id: videos[indexPath.row].id)
    }
}

extension LectureDetailsVC: VdoPlayerViewControllerDelegate {
    
    func didClosePlayer(controller: UIViewController) {
        controller.dismiss(animated: false)
        UIApplication.appDelegate.removeWatermark()
        
    }
    
    
    
}

extension LectureDetailsVC: AssetPlaybackDelegate {
    
    func streamPlaybackManager(playerReadyToPlay player: AVPlayer) {
        self.vdoPlayer = player
        player.play()
    }
    
    func streamPlaybackManager(playerCurrentItemDidChange player: AVPlayer) {
        self.vdoPlayer = player
    }
    
    func streamLoadError(error: VdoFramework.VdoError) {
        showSimpleAlert(title: "خطأ", message: "عذراً، حدث خطأ أثناء تحميل الفيديو. يرجى المحاولة مرة أخرى لاحقاً.")
    }
    
    
}


