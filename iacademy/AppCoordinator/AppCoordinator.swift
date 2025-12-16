//
//  AppCoordinator.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import UIKit
import VdoFramework

class AppCoordinator {

    static let shared = AppCoordinator()
    private var navigationController: UINavigationController?
    private init() {}
    
    func start(in window: UIWindow?) {
        let entryPoint = build(for: .AppEntryPoint)
        let navController = UINavigationController(rootViewController: entryPoint)
        navController.navigationBar.isHidden = true
        navController.view.semanticContentAttribute = .forceRightToLeft
        navigationController = navController
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
    }
    
    func navigate(to destination: Destination) {
        let viewController = build(for: destination)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func present(to destination: Destination) {
        let viewController = build(for: destination)
        navigationController?.present(viewController, animated: true)
    }
    
    func setRoot(to destination: Destination) {
        let viewController = build(for: destination)
        navigationController?.setViewControllers([viewController], animated: true)
    }
    
    func back() {
        navigationController?.popViewController(animated: true)
    }
    
    func backToRoot() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func dismiss() {
        navigationController?.dismiss(animated: true)
    }
    
    func removeFromNavigationStack(destination: Destination) {
        if var viewControllers = navigationController?.viewControllers {
            switch destination {
            case .AppEntryPoint: viewControllers.removeAll(where: { $0 is AppEntryPointVC })
            case .login: viewControllers.removeAll(where: { $0 is LoginVC })
            case .register: viewControllers.removeAll(where: { $0 is RegisterVC })
            case .userVerification: viewControllers.removeAll(where: { $0 is UserVerificationVC })
            default: return
            }
            navigationController?.setViewControllers(viewControllers, animated: true)
        }
    }
    
    func getTopViewController(from root: UIViewController?) -> UIViewController? {
        if let nav = root as? UINavigationController {
            return getTopViewController(from: nav.visibleViewController)
        } else if let tab = root as? UITabBarController {
            return getTopViewController(from: tab.selectedViewController)
        } else if let presented = root?.presentedViewController {
            return getTopViewController(from: presented)
        } else {
            return root
        }
    }
    
    func build(for destination: Destination) -> UIViewController {
        switch destination {
        case .AppEntryPoint:
            return AppEntryPointVC()
        case .login:
            return LoginVC()
        case .register:
            return RegisterVC()
        case .userVerification:
            return UserVerificationVC()
        case .userVerificationWebView(let url):
            let vc = UserVerificationWebViewVC()
            vc.url = url
            return vc
        case .resetPassword:
            return ResetPasswordVC()
        case .otp:
            return OtpVC()
        case .main:
            return MainTabbarController()
        case .home:
            return HomeVC()
        case .myCourses:
            return MyCoursesVC()
        case .notifications:
            return NotificationsVC()
        case .profile:
            return ProfileVC()
        case .editProfile(let onUpdate):
            let vc = EditProfileVC()
            vc.onProfileUpdated = onUpdate
            return vc
        case .changePassword:
            return ChangePasswordVC()
        case .settings:
            return SettingsVC()
        case .courseDetails(let courseID):
            let vc = CourseDetailsVC()
            vc.courseID = courseID
            return vc
        case .lecturesDetails(let lectureID, let lectureName):
            let vc = LectureDetailsVC()
            vc.lectureID = lectureID
            vc.lectureName = lectureName
            return vc
        case .teacherCourses(let teacherID, let teacherName):
            let vc = TeacherCoursesVC()
            vc.teacherID = teacherID
            vc.teacherName = teacherName
            return vc
        case .setNewPassword(let token):
            let vc = SetNewPasswordVC()
            vc.token = token
            return vc
        case .standardPlayer(let url):
            let vc = StandardPlayerViewController(videoURL: url)
            vc.modalPresentationStyle = .fullScreen
            return vc
        case .adaptivePlayer(let qualities):
            let vc = AdaptivePlayerViewController(availableQualities: qualities)
            vc.modalPresentationStyle = .fullScreen
            return vc
        case .vdoCipherPlayer(let videoID, let otp, let playbackInfo):
            let vc = VdoCipherPlayerViewController(videoID: videoID, otp: otp, playbackInfo: playbackInfo)
            vc.modalPresentationStyle = .fullScreen
            return vc
        case .drmPlayer(let videoURL, let licenseURL, let certificateURL):
            let vc = DRMPlayerViewController(videoURL: videoURL, licenseURL: licenseURL, certificateURL: certificateURL)
            vc.modalPresentationStyle = .fullScreen
            return vc
        case .idVerification:
            return IDVerificationVC()
        case .securityBlocker:
            return SecurityBlockerVC()
        }
    }
    
    enum Destination {
        case AppEntryPoint
        case login
        case register
        case userVerification
        case userVerificationWebView(url: String)
        case resetPassword
        case otp
        case main
        case home
        case myCourses
        case notifications
        case profile
        case editProfile(onUpdate: (() -> Void)? = nil)
        case changePassword
        case settings
        case courseDetails(courseID: Int)
        case lecturesDetails(lectureID: String, lectureName: String)
        case teacherCourses(teacherID: String?, teacherName: String?)
        case setNewPassword(token: String)
        case standardPlayer(url: String)
        case adaptivePlayer(qualities: [(String, String)]) // [Quality -> URL]
        case vdoCipherPlayer(videoID: String, otp: String, playbackInfo: String)
        case drmPlayer(videoURL: String, licenseURL: String, certificateURL: String)
        case idVerification
        case securityBlocker
    }
}

extension AppCoordinator {
    
    func isDisplayingPlayer() -> Bool {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
              let topVC = getTopViewController(from: window.rootViewController) else {
            return false
        }
        let isPlayer = topVC.isKindOfOrPresented(by: [
            StandardPlayerViewController.self,
            AdaptivePlayerViewController.self,
            VdoPlayerViewController.self,
            DRMPlayerViewController.self,
        ])
//        print("topVC is \(topVC.description) - isPlayer = \(isPlayer)")
        return isPlayer
    }
}


extension UIViewController {
    func isKindOfOrPresented(by types: [AnyClass]) -> Bool {
        var vc: UIViewController? = self
        while let current = vc {
            if types.contains(where: { current.isKind(of: $0) }) {
                return true
            }
            vc = current.presentingViewController
        }
        return false
    }
}
