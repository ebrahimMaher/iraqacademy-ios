//
//  OTPTextField.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import UIKit


class OTPTextField: UITextField {
    
    var onDeleteBackward: (() -> ())?
    
    override func deleteBackward() {
        super.deleteBackward()
        onDeleteBackward?()
    }
}
