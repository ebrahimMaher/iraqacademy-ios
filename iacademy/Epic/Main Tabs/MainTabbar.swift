//
//  MainTabbar.swift
//  iacademy
//
//  Created by Marwan Osama on 15/12/2025.
//

import UIKit

class MainTabbarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let homeVC = AppCoordinator.shared.build(for: .home)
//        let myCoursesVC = AppCoordinator.shared.build(for: .myCourses)
//        let notificationsVC = AppCoordinator.shared.build(for: .notifications)
//        let profileVC = AppCoordinator.shared.build(for: .profile)
//        
//        homeVC.tabBarItem = .init(title: "الرئيسية",
//                                  image: .init(named: "tabbar_home_unselected"),
//                                  selectedImage: .init(named: "tabbar_home_selected"))
//        myCoursesVC.tabBarItem = .init(title: "دوراتي",
//                                       image: .init(named: "tabbar_courses_unselected"),
//                                       selectedImage: .init(named: "tabbar_courses_selected"))
//        notificationsVC.tabBarItem = .init(title: "الإشعارات",
//                                           image: .init(named: "tabbar_notifications_unselected"),
//                                           selectedImage: .init(named: "tabbar_notifications_selected"))
//        profileVC.tabBarItem = .init(title: "حسابي",
//                                     image: .init(named: "tabbar_profile_unselected"),
//                                     selectedImage: .init(named: "tabbar_profile_selected"))
        
//        viewControllers = [homeVC, myCoursesVC, notificationsVC, profileVC]
        viewControllers = []
        
        tabBar.tintColor = .Blue_Brand_500
        tabBar.unselectedItemTintColor = .Gray_300
        tabBar.semanticContentAttribute = .forceRightToLeft
        tabBar.backgroundColor = .white
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        tabBar.layer.shadowColor = UIColor.lightGray.cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -0.3)
        tabBar.layer.shadowOpacity = 0.3
        tabBar.layer.shadowRadius = 1

    }
    
}
