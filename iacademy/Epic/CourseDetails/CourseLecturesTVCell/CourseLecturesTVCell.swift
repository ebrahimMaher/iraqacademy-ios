//
//  CourseLecturesTVCell.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import UIKit

class CourseLecturesTVCell: UITableViewCell {

    @IBOutlet weak var lectureNameLabel: UILabel!
    @IBOutlet weak var videosCountLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configure(_ lecture: CourseDetailsLecture) {
        lectureNameLabel.text = lecture.name
        setCoursesLecutresCountLabel(lecture)
    }
    
    private func setCoursesLecutresCountLabel(_ courseDetails: CourseDetailsLecture) {
        if let lecturesCount = courseDetails.videosCount {
            switch lecturesCount {
            case 3, 4, 5, 6, 7, 8, 9, 10:
                videosCountLabel.text = "\(lecturesCount) محاضرات"
            case 0:
                videosCountLabel.text = "لا يوجد محاضرات"
            case 1:
                videosCountLabel.text = "محاضرة واحدة"
            case 2:
                videosCountLabel.text = "محاضرتين"
            default:
                videosCountLabel.text = "\(lecturesCount) محاضرة"
            }
        } else {
            videosCountLabel.text = "لا يوجد محاضرات"
        }
    }
    
}
