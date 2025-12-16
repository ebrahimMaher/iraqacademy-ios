//
//  AdaptivePlayerViewController.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import UIKit
import AVFoundation

class AdaptivePlayerViewController: UIViewController {
    
    private var player = AVPlayer()
    private var playerLayer: AVPlayerLayer!
    
    private let dismissButton = UIButton(type: .system)
    private let muteButton = UIButton(type: .system)
    private let qualityButton = UIButton(type: .system)
    private let playPauseButton = UIButton(type: .system)
    private let rewindButton = UIButton(type: .system)
    private let forwardButton = UIButton(type: .system)
    private let slider = UISlider()
    private let currentTimeLabel = UILabel()
    private let durationLabel = UILabel()
    
    private var isMuted = false
    
    private var playbackControlsStacks: [UIStackView] = []
    private var controlsHidden = false
    private var hideControlsTimer: Timer?
    private var timeObserver: Any?
    
    var availableQualities: [(quality: String, url: String)]

    init(availableQualities: [(quality: String, url: String)]) {
        self.availableQualities = availableQualities
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.landscapeLeft, .landscapeRight]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenRecordingChanged),
            name: UIScreen.capturedDidChangeNotification,
            object: nil)
        setupPlayer()
        setupUI()
        setupTimeObserver()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playerDidAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideControlsTimer?.invalidate()
        hideControlsTimer = nil
        playerDidDismiss()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = view.bounds
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupPlayer() {
        guard availableQualities.indices.contains(0),
              let url = URL(string: availableQualities[0].url) else { return }
        qualityButton.setTitle(availableQualities[0].quality, for: .normal)
        let item = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: item)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspect
        view.layer.addSublayer(playerLayer)
        player.play()
        
        screenRecordingChanged()
    }

    private func setupUI() {
        view.backgroundColor = .black
        
        let tapView = UIView(frame: view.bounds)
        tapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tapView.backgroundColor = .clear
        view.addSubview(tapView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        tapView.addGestureRecognizer(tapGesture)
        
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.tintColor = .white
        dismissButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        
        muteButton.setImage(UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        muteButton.tintColor = .white
        muteButton.addTarget(self, action: #selector(toggleMute), for: .touchUpInside)
        
        qualityButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        qualityButton.layer.cornerRadius = 10
        qualityButton.setTitleColor(.white, for: .normal)
        qualityButton.addTarget(self, action: #selector(didTapQuality), for: .touchUpInside)
        qualityButton.backgroundColor = .black.withAlphaComponent(0.3)

        let topStack = UIStackView(arrangedSubviews: [dismissButton, UIView(), qualityButton, muteButton])
        topStack.axis = .horizontal
        topStack.distribution = .fill
        topStack.spacing = 12
        topStack.translatesAutoresizingMaskIntoConstraints = false
        playbackControlsStacks.append(topStack)
        view.addSubview(topStack)
        
        
        rewindButton.setImage(UIImage(systemName: "gobackward.10"), for: .normal)
        rewindButton.tintColor = .white
        rewindButton.addTarget(self, action: #selector(seekBack), for: .touchUpInside)
        rewindButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        rewindButton.layer.cornerRadius = 10
        rewindButton.backgroundColor = .black.withAlphaComponent(0.3)

        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        playPauseButton.tintColor = .white
        playPauseButton.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)
        playPauseButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        playPauseButton.layer.cornerRadius = 10
        playPauseButton.backgroundColor = .black.withAlphaComponent(0.3)

        forwardButton.setImage(UIImage(systemName: "goforward.10"), for: .normal)
        forwardButton.tintColor = .white
        forwardButton.addTarget(self, action: #selector(seekForward), for: .touchUpInside)
        forwardButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        forwardButton.layer.cornerRadius = 10
        forwardButton.backgroundColor = .black.withAlphaComponent(0.3)

        let centerStack = UIStackView(arrangedSubviews: [rewindButton, playPauseButton, forwardButton])
        centerStack.axis = .horizontal
        centerStack.spacing = 40
        centerStack.alignment = .center
        centerStack.translatesAutoresizingMaskIntoConstraints = false
        playbackControlsStacks.append(centerStack)
        view.addSubview(centerStack)

        
        currentTimeLabel.text = "0:00"
        currentTimeLabel.textColor = .white
        currentTimeLabel.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)

        durationLabel.text = "-0:00"
        durationLabel.textColor = .white
        durationLabel.font = .monospacedDigitSystemFont(ofSize: 12, weight: .regular)

        slider.tintColor = .white
        let thumbImage = UIImage.circle(diameter: 18, color: .white)
        slider.setThumbImage(thumbImage, for: .normal)
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderDidEnd), for: .touchUpInside)

        let bottomStack = UIStackView(arrangedSubviews: [currentTimeLabel, slider, durationLabel])
        bottomStack.axis = .horizontal
        bottomStack.spacing = 8
        bottomStack.alignment = .center
        bottomStack.translatesAutoresizingMaskIntoConstraints = false
        playbackControlsStacks.append(bottomStack)
        view.addSubview(bottomStack)

        
        NSLayoutConstraint.activate([
            topStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            topStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            topStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            centerStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            bottomStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            bottomStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            bottomStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
        
        
        startHideControlsTimer()
    }
    
    @objc private func viewTapped() {
        controlsHidden.toggle()
        UIView.animate(withDuration: 0.3) {
            self.playbackControlsStacks.forEach {
                $0.alpha = self.controlsHidden ? 0 : 1
            }
        }
        
        if !controlsHidden {
            startHideControlsTimer()
        } else {
            hideControlsTimer?.invalidate()
        }
    }

    private func startHideControlsTimer() {
        hideControlsTimer?.invalidate()
        hideControlsTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
            self?.hideControls()
        }
    }

    private func hideControls() {
        controlsHidden = true
        UIView.animate(withDuration: 0.3) {
            self.playbackControlsStacks.forEach {
                $0.alpha = 0
            }
        }
    }

    private func setupTimeObserver() {
        self.timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] time in
            guard let self, let duration = self.player.currentItem?.duration else { return }
            let totalSeconds = CMTimeGetSeconds(duration)
            let currentSeconds = CMTimeGetSeconds(time)
            self.slider.value = Float(currentSeconds / totalSeconds)
            self.currentTimeLabel.text = formatTime(currentSeconds)
            self.durationLabel.text = "-\(formatTime(totalSeconds - currentSeconds))"
        }
    }
    
    private func removeTimeObserver() {
        guard timeObserver != nil else { return }
        player.removeTimeObserver(timeObserver!)
        timeObserver = nil
    }

    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite else { return "0:00" }
        let mins = Int(seconds / 60)
        let secs = Int(seconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d", mins, secs)
    }

    @objc private func togglePlayPause() {
        startHideControlsTimer()
        if player.timeControlStatus == .paused {
            player.play()
            playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            player.pause()
            playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
    }
    
    @objc private func screenRecordingChanged() {
        if UIScreen.main.isCaptured {
            self.player.pause()
            UIApplication.appDelegate.removeWatermark()
            self.dismiss(animated: true, completion: nil)
        }
    }

    @objc private func dismissTapped() {
        dismiss(animated: true)
    }

    @objc private func toggleMute() {
        startHideControlsTimer()
        isMuted.toggle()
        player.isMuted = isMuted
        muteButton.setImage(UIImage(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill"), for: .normal)
    }

    @objc private func seekBack() {
        startHideControlsTimer()
        let currentTime = player.currentTime().seconds
        let targetTime = max(currentTime - 10, 0)
        player.seek(to: CMTime(seconds: targetTime, preferredTimescale: 600))
    }

    @objc private func seekForward() {
        startHideControlsTimer()
        guard let duration = player.currentItem?.duration else { return }
        let currentTime = player.currentTime().seconds
        let maxTime = CMTimeGetSeconds(duration)
        let targetTime = min(currentTime + 10, maxTime)
        player.seek(to: CMTime(seconds: targetTime, preferredTimescale: 600))
    }

    @objc private func sliderChanged() {
        player.pause()
        playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        removeTimeObserver()
        startHideControlsTimer()
        guard let duration = player.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        let value = Double(slider.value) * totalSeconds
        player.seek(to: CMTime(seconds: value, preferredTimescale: 600))
        currentTimeLabel.text = formatTime(value)
        durationLabel.text = "-\(formatTime(totalSeconds - value))"

    }
    
    @objc private func sliderDidEnd() {
        setupTimeObserver()
        player.play()
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
    
    @objc private func didTapQuality() {
        let alert = UIAlertController(title: "اختر جودة", message: nil, preferredStyle: .actionSheet)
        alert.overrideUserInterfaceStyle = .dark
        for quality in availableQualities {
            alert.addAction(.init(title: quality.quality, style: .default, handler: { _ in
                self.switchQuality(to: quality.url)
                self.qualityButton.setTitle(quality.quality, for: .normal)
            }))
        }
        alert.addAction(UIAlertAction(title: "إلغاء", style: .cancel, handler: nil))
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        present(alert, animated: true)
    }
}

extension AdaptivePlayerViewController: PlayerViewController {
    
    func play() {
        self.player.play()
    }
    
    func pause() {
        self.player.pause()
    }
    
    func seek(to time: CMTime, completion: ((Bool) -> Void)?) {
        self.player.seek(to: time) { finished in
            completion?(finished)
        }
    }
    
}

extension AdaptivePlayerViewController: QualitySwitchableController {
    
    func switchQuality(to url: String) {
        let currentTime = player.currentTime()
        let wasPlaying = (player.rate) > 0
        
        if let url = URL(string: url) {
            let newItem = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: newItem)
            player.seek(to: currentTime) { [weak self] _ in
                if wasPlaying {
                    self?.player.play()
                }
            }
        }
    }
    
    
}
