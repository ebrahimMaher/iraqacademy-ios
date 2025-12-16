//
//  UIImage.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import UIKit

extension UIImage {
    static func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        let rect = CGRect(origin: .zero, size: CGSize(width: diameter, height: diameter))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fillEllipse(in: rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}
