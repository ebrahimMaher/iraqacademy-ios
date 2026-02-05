//
//  AppButton.swift
//  iacademy
//
//  Created by Marwan Osama on 21/01/2026.
//

import UIKit

@IBDesignable
class AppButton: UIButton {

    @IBInspectable var fontWeight: Int = UIFont.AppFontWeight.medium.rawValue {
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
        guard
            let weight = UIFont.AppFontWeight(rawValue: fontWeight),
            let titleLabel = titleLabel
        else { return }

        titleLabel.font = UIFont.avenir(
            weight: weight.uiWeight,
            size: titleLabel.font.pointSize
        )
    }
}
