//
//  UIFont.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import UIKit

extension UIFont {
    
    @objc enum AppFontWeight: Int {
        case light = 0
        case regular
        case medium
        case semibold
        case bold

        var uiWeight: UIFont.Weight {
            switch self {
            case .light: return .light
            case .regular: return .regular
            case .medium: return .medium
            case .semibold: return .semibold
            case .bold: return .bold
            }
        }
    }
    
    static func rubikFont(weight: UIFont.Weight, size: CGFloat) -> UIFont {
        switch weight {
        case .black:
            return UIFont(name: "Rubik-Black", size: size)!
        case .bold:
            return UIFont(name: "Rubik-Bold", size: size)!
        case .semibold:
            return UIFont(name: "Rubik-SemiBold", size: size)!
        case .heavy:
            return UIFont(name: "Rubik-ExtraBold", size: size)!
        case .light:
            return UIFont(name: "Rubik-Light", size: size)!
        case .medium:
            return UIFont(name: "Rubik-Medium", size: size)!
        case .regular:
            return UIFont(name: "Rubik-Regular", size: size)!
        default:
            return UIFont(name: "Rubik-Medium", size: size)!
        }
    }
    
    static func ibmPlexFont(weight: UIFont.Weight, size: CGFloat) -> UIFont {
        switch weight {
        case .ultraLight:
            return UIFont(name: "IBMPlexSansArabic-ExtraLight", size: size)!
        case .bold:
            return UIFont(name: "IBMPlexSansArabic-Bold", size: size)!
        case .semibold:
            return UIFont(name: "IBMPlexSansArabic-SemiBold", size: size)!
        case .light:
            return UIFont(name: "IBMPlexSansArabic-Light", size: size)!
        case .medium:
            return UIFont(name: "IBMPlexSansArabic-Medium", size: size)!
        case .regular:
            return UIFont(name: "IBMPlexSansArabic-Regular", size: size)!
        case .thin:
            return UIFont(name: "IBMPlexSansArabic-Thin", size: size)!
        default:
            return UIFont(name: "IBMPlexSansArabic-Medium", size: size)!
        }
    }
    
    static func avenir(weight: UIFont.Weight, size: CGFloat) -> UIFont {
        switch weight {
        case .light:
            return UIFont(name: "AvenirArabic-Light", size: size)!
        case .regular:
            return UIFont(name: "AvenirArabic-Book", size: size)!
        case .medium:
            return UIFont(name: "AvenirArabic-Medium", size: size)!
        case .semibold:
            return UIFont(name: "AvenirArabic-Heavy", size: size)!
        case .bold:
            return UIFont(name: "AvenirArabic-Black", size: size)!
        default:
            return UIFont(name: "AvenirArabic-Medium", size: size)!
        }
    }
}
