//
//  HomeTeachersCVCell.swift
//  iacademy
//
//  Created by Marwan Osama on 15/12/2025.
//

import UIKit
import Kingfisher

class HomeTeachersCVCell: UICollectionViewCell {
    
    
    @IBOutlet weak var teacherNameLabel: UILabel!
    @IBOutlet weak var teacherImageView: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
                
    }
    
    func configure(_ teacher: HomeTeacherModel) {
        teacherNameLabel.text = teacher.name
        teacherNameLabel.adjustsFontSizeToFitWidth = true
        teacherImageView.kf.indicatorType = .activity
        teacherImageView.kf.setImage(with: URL(string: teacher.avatar ?? ""), placeholder: UIImage(named: "avatar_placeholder"), options: [.transition(.fade(0.3)), .cacheMemoryOnly])

    }

}
