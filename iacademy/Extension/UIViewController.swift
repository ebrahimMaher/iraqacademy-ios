//
//  UIViewController.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import UIKit

extension UIViewController {
    
    
    func showSimpleAlert(title: String, message: String, okAction: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.alignment = .center
        
        let attributedTitle = NSAttributedString(string: title, attributes: [
            .paragraphStyle: titleParagraphStyle,
            .font: UIFont.rubikFont(weight: .medium, size: 17)
        ])
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributedMessage = NSAttributedString(string: message, attributes: [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.rubikFont(weight: .regular, size: 13)
        ])
        alert.setValue(attributedMessage, forKey: "attributedMessage")

        let ok = UIAlertAction(title: "حسنآ", style: .default) { _ in
            okAction?()
        }
        alert.addAction(ok)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        present(alert, animated: true, completion: nil)
    }
    
    func showRightAlignedAlert(title: String, message: String) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.alignment = .center
        
        let attributedTitle = NSAttributedString(string: title, attributes: [
            .paragraphStyle: titleParagraphStyle,
            .font: UIFont.rubikFont(weight: .medium, size: 17)
        ])
        alert.setValue(attributedTitle, forKey: "attributedTitle")


        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right

        let attributedMessage = NSAttributedString(string: message, attributes: [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.rubikFont(weight: .regular, size: 13)
        ])

        alert.setValue(attributedMessage, forKey: "attributedMessage")

        alert.addAction(UIAlertAction(title: "حسنآ", style: .default))
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        present(alert, animated: true)
    }
    
    func showAlertWithCancel(title: String, message: String, okActionName: String, okAction: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.alignment = .center
        
        let attributedTitle = NSAttributedString(string: title, attributes: [
            .paragraphStyle: titleParagraphStyle,
            .font: UIFont.rubikFont(weight: .medium, size: 17)
        ])
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributedMessage = NSAttributedString(string: message, attributes: [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.rubikFont(weight: .regular, size: 13)
        ])
        alert.setValue(attributedMessage, forKey: "attributedMessage")
        
        let ok = UIAlertAction(title: okActionName, style: .default) { _ in
            okAction?()
        }
        let cancelAction = UIAlertAction(title: "إغلاق", style: .destructive)
        alert.addAction(ok)
        alert.addAction(cancelAction)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        present(alert, animated: true, completion: nil)
    }

    
}

extension UIViewController {
    func findViewController<T: UIViewController>(ofType type: T.Type) -> T? {
        if let vc = self as? T {
            return vc
        }
        for child in children {
            if let match = child.findViewController(ofType: type) {
                return match
            }
        }
        if let nav = self as? UINavigationController {
            return nav.viewControllers.compactMap { $0 as? T }.first
        }
        if let presented = self.presentedViewController {
            return presented.findViewController(ofType: type)
        }
        return nil
    }
}
