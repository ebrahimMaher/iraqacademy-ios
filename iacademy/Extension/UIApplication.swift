//
//  UIApplication.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import UIKit

extension UIApplication {
    
    
    static var appDelegate: AppDelegate {
        return shared.delegate as! AppDelegate
    }
    
    
    func topMostViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        .first?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topMostViewController(base: nav.visibleViewController)
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topMostViewController(base: selected)
        } else if let presented = base?.presentedViewController {
            return topMostViewController(base: presented)
        }
        return base
    }
    
    
}
