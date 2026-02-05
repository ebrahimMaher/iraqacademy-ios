//
//  AppLabel.swift
//  iacademy
//
//  Created by Marwan Osama on 21/01/2026.
//

import UIKit

@IBDesignable
class AppLabel: UILabel {

    @IBInspectable var fontWeight: Int = UIFont.AppFontWeight.regular.rawValue {
        didSet { applyFont() }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        applyFont()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        applyFont()
    }

    private func applyFont() {
        guard let weight = UIFont.AppFontWeight(rawValue: fontWeight) else { return }
        font = UIFont.avenir(weight: weight.uiWeight, size: font.pointSize)
    }
}
