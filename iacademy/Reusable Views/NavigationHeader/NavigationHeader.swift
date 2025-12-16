//
//  NavigationHeader.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import UIKit

@IBDesignable
class NavigationHeader: UIView {


    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var backButton: UIButton!

    
    @IBInspectable var title: String = "" {
        didSet {
            titleLabel?.text = title
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit()
    }

    // MARK: - Load XIB

    private func commonInit() {
        let bundle = Bundle(for: type(of: self))
        bundle.loadNibNamed("NavigationHeader", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        titleLabel.text = title
        
        backButton.layer.cornerRadius = 12
        backButton.layer.borderWidth = 1
        backButton.layer.borderColor = UIColor.Gray_100.cgColor
    }

    @IBAction private func backButtonTapped(_ sender: UIButton) {
        if let vc = findViewController() {
            vc.navigationController?.popViewController(animated: true)
        }
    }

    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let next = responder?.next {
            if let vc = next as? UIViewController {
                return vc
            }
            responder = next
        }
        return nil
    }
}
