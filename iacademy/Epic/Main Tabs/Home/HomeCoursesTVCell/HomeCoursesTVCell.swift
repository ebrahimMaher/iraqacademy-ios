//
//  HomeCoursesTVCell.swift
//  iacademy
//
//  Created by Marwan Osama on 15/12/2025.
//

import UIKit

class HomeCoursesTVCell: UITableViewCell {

    @IBOutlet weak var courseNameLabel: UILabel!
    
    @IBOutlet weak var lineSeparator: UILabel!
    
    @IBOutlet weak var courseVideosCountContainer: UIStackView!
    @IBOutlet weak var courseVideosCount: UILabel!
    
    @IBOutlet weak var courseSpecialityContainer: UIStackView!
    @IBOutlet weak var courseSpecialityLabel: UILabel!
    
    @IBOutlet weak var courseTeacherContainer: UIStackView!
    @IBOutlet weak var courseTeacherLabel: UILabel!
    
    @IBOutlet weak var mainStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configure(_ course: HomeCourseModel) {
        courseNameLabel.text = course.name
        courseVideosCount.text = "\((course.videos ?? []).count) محاضرة"
        lineSeparator.isHidden = true
        courseTeacherContainer.isHidden = true
        courseSpecialityContainer.isHidden = true
        mainStackView.spacing = 20
        
    }
    
    
}

