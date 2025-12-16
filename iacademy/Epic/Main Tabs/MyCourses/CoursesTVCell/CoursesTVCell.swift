//
//  CoursesTVCell.swift
//  iacademy
//
//  Created by Marwan Osama on 15/12/2025.
//

import UIKit

class CoursesTVCell: UITableViewCell {
    
    @IBOutlet weak var courseNameLabel: UILabel!
    
    @IBOutlet weak var lineSeparator: UILabel!
    
    @IBOutlet weak var courseVideosCountContainer: UIStackView!
    @IBOutlet weak var courseVideosCount: UILabel!
    
    @IBOutlet weak var courseChaptersContainer: UIStackView!
    @IBOutlet weak var courseChaptersLabel: UILabel!
    
    @IBOutlet weak var courseTeacherContainer: UIStackView!
    @IBOutlet weak var courseTeacherLabel: UILabel!
    
    @IBOutlet weak var mainStackView: UIStackView!


    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func configure(_ myCourseModel: MyCourseModel) {
        courseNameLabel.text = myCourseModel.name
        setCoursesVideoCountLabel(myCourseModel.videosCount)
        setCoursesLecutresCountLabel(myCourseModel.lecturesCount)
        if let teacherName = myCourseModel.teacher?.name {
            courseTeacherLabel.text = teacherName
        } else {
            courseTeacherLabel.text = ""
        }
        
    }
    
    func configure(_ teacherCourse: TeacherCourseResponseModel.Courses) {
        courseNameLabel.text = teacherCourse.name
        setCoursesVideoCountLabel(teacherCourse.videosCount)
        setCoursesLecutresCountLabel(teacherCourse.lecturesCount)
        if let teacherName = teacherCourse.teacher?.name {
            courseTeacherLabel.text = teacherName
        } else {
            courseTeacherLabel.text = ""
        }

    }
    
    private func setCoursesVideoCountLabel(_ videosCount: Int?) {
        if let lecturesCount = videosCount {
            switch lecturesCount {
            case 0:
                courseVideosCount.text = "لا يوجد محاضرات"
            case 1:
                courseVideosCount.text = "محاضرة واحدة"
            case 2:
                courseVideosCount.text = "محاضرتين"
            case 3, 4, 5, 6, 7, 8, 9, 10:
                courseVideosCount.text = "\(lecturesCount) محاضرات"
            default:
                courseVideosCount.text = "\(lecturesCount) محاضرة"
            }
        } else {
            courseVideosCount.text = "لا يوجد محاضرات"
        }
    }
    
    private func setCoursesLecutresCountLabel(_ lecturesCount: Int?) {
        if let lecturesCount = lecturesCount {
            switch lecturesCount {
            case 3, 4, 5, 6, 7, 8, 9, 10:
                courseChaptersLabel.text = "\(lecturesCount) فصول"
            case 0:
                courseChaptersLabel.text = "لا يوجد فصول"
            case 1:
                courseChaptersLabel.text = "فصل واحدة"
            case 2:
                courseChaptersLabel.text = "فصلين"
            default:
                courseChaptersLabel.text = "\(lecturesCount) فصل"
            }
        } else {
            courseChaptersLabel.text = "لا يوجد فصول"
        }
    }

    
    
}
