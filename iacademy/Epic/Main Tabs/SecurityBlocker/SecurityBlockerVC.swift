//
//  SecurityBlockerVC.swift
//  iacademy
//
//  Created by Marwan Osama on 15/12/2025.
//

import UIKit

class SecurityBlockerVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        headerLbl.text = "عذرًا! هناك خطأ ما 🚫"
        headerLbl.font = UIFont.rubikFont(weight: .medium, size: 24)
        messageLbl.text = "تم اكتشاف مخاطر أمنية محتملة على هذا الجهاز. من أجل الأمان، تم تقييد الوصول إلى التطبيق."
        messageLbl.font = UIFont.rubikFont(weight: .regular, size: 16)
    }
}
