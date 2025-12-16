//
//  UITableViewCell.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import UIKit

extension UITableViewCell {
    static var identifier: String {
        return String(describing: self)
    }
    
    static var nib : UINib{
        return UINib(nibName: identifier, bundle: nil)
    }
}
