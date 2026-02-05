//
//  AppDelegate.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import UIKit
import IQKeyboardManager
import netfox
import FirebaseCore
import FirebaseMessaging
import AVKit
import VdoFramework

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var overlayWindow: UIWindow?
    var orientationObserver: NSObjectProtocol?
    var floatingWatermarkTimer: Timer?
    private var screenCaptureOverlay: UIView?
    private var floatingWatermark: FloatingWatermark!
    private var screenRecordingTimer: Timer?
    private var screenRecordingCounter: Int = 5
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        initializeLibraries()
        initializeScreenRecordingObserver()
        setupNotifications(application)
        AppCoordinator.shared.start(in: window)
        
        for family in UIFont.familyNames.sorted() {
            print("Family: \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("   \(name)")
            }
        }
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == "nippuracademy", url.host == "telegram-success" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if let window = UIApplication.shared.windows.first,
                   let rootVC = window.rootViewController {
//                    let userVerificationVC = rootVC.findViewController(ofType: UserVerificationVC.self)
//                    userVerificationVC?.safariVC?.dismiss(animated: true)
                    CacheClient.shared.isAccountVerified = true
                    AppCoordinator.shared.setRoot(to: .main)
                }
                
            }
            return true
        }
        
        if url.scheme == "nippuracademy", url.host == "telegram-reset-password-success" {
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let token = components.queryItems?.first(where: { $0.name == "reset_token" })?.value {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    if let window = UIApplication.shared.windows.first,
                       let rootVC = window.rootViewController {
//                        let resetPasswordVC = rootVC.findViewController(ofType: ResetPasswordVC.self)
//                        resetPasswordVC?.safariVC?.dismiss(animated: true)
//                        AppCoordinator.shared.navigate(to: .setNewPassword(token: token))
                    }
                    
                }
                return true
            }
        }
        
        return false
    }
    
    private func initializeLibraries() {
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        
        #if DEBUG
        NFX.sharedInstance().start()
        #endif
        
        
    }
    
    func addFloatingWatermark() {
        guard floatingWatermark == nil, let userID = CacheClient.shared.userModel?.id else { return }
        floatingWatermark = .init(userID: "\(userID)")
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
                        
            window.addSubview(floatingWatermark)
            window.bringSubviewToFront(floatingWatermark)
            floatingWatermark.startAnimation(in: window)
        }
    }
    
    func removeWatermark() {
        guard floatingWatermark != nil else { return }
        floatingWatermark.removeFromSuperview()
        floatingWatermark = nil
    }
    
    private func startWatermarkTimer() {
        stopWatermarkTimer()
        floatingWatermarkTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            let isPlayer = AppCoordinator.shared.isDisplayingPlayer()
            if !isPlayer {
                self.removeWatermark()
            }
        })
    }
    
    private func stopWatermarkTimer() {
        floatingWatermarkTimer?.invalidate()
        floatingWatermarkTimer = nil
    }
        
    private func setupNotifications(_ application: UIApplication) {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            if (granted) {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }

    }
    
    private func initializeScreenRecordingObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(capturedChange),
            name: UIScreen.capturedDidChangeNotification,
            object: nil)
    }
    
    @objc func capturedChange() {
        if UIScreen.main.isCaptured {
            guard overlayWindow == nil else { return }

            let windowScene = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first

            let newWindow = UIWindow(windowScene: windowScene!)
            newWindow.frame = UIScreen.main.bounds
            newWindow.backgroundColor = .clear
            newWindow.windowLevel = .alert + 1
            newWindow.isHidden = false

            let overlay = UIView()
            overlay.backgroundColor = .black
            overlay.translatesAutoresizingMaskIntoConstraints = false

            let label = UILabel()
            label.text = "ممنوع تسجيل الشاشة نظرا لحقوق المحتوى، يرجى إيقاف مسجل الشاشة."
            label.numberOfLines = 0
            label.textColor = .white
            label.font = .rubikFont(weight: .medium, size: 20)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false

            overlay.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
                label.leadingAnchor.constraint(greaterThanOrEqualTo: overlay.leadingAnchor, constant: 30),
                label.trailingAnchor.constraint(lessThanOrEqualTo: overlay.trailingAnchor, constant: -30)
            ])

            newWindow.addSubview(overlay)
            NSLayoutConstraint.activate([
                overlay.topAnchor.constraint(equalTo: newWindow.topAnchor),
                overlay.bottomAnchor.constraint(equalTo: newWindow.bottomAnchor),
                overlay.leadingAnchor.constraint(equalTo: newWindow.leadingAnchor),
                overlay.trailingAnchor.constraint(equalTo: newWindow.trailingAnchor),
            ])

            overlayWindow = newWindow
            startScreenRecordingTimer()

            orientationObserver = NotificationCenter.default.addObserver(
                forName: UIApplication.didChangeStatusBarOrientationNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.overlayWindow?.frame = UIScreen.main.bounds
            }

        } else {
            overlayWindow?.isHidden = true
            overlayWindow = nil
            stopScreenRecordingTimer()

            if let observer = orientationObserver {
                NotificationCenter.default.removeObserver(observer)
                orientationObserver = nil
            }
        }
    }
    
    private func startScreenRecordingTimer() {
        screenRecordingCounter = 5
        screenRecordingTimer?.invalidate()
        screenRecordingTimer = nil
        screenRecordingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            if screenRecordingCounter < 1 {
                screenRecordingTimer?.invalidate()
                screenRecordingTimer = nil
                exit(0)
            } else {
                screenRecordingCounter -= 1
            }
        })
    }
    
    private func stopScreenRecordingTimer() {
        screenRecordingTimer?.invalidate()
        screenRecordingTimer = nil
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        startWatermarkTimer()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        stopWatermarkTimer()
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        if let fcmToken = fcmToken {
            CacheClient.shared.fcmToken = fcmToken
        }
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .banner, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
}

