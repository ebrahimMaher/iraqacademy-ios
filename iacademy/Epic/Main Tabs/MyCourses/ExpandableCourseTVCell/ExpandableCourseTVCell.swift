//
//  ExpandableCourseTVCell.swift
//  iacademy
//
//  Created by Marwan Osama on 15/12/2025.
//

import UIKit
import Kingfisher

class ExpandableCourseTVCell: UITableViewCell {
    
    @IBOutlet weak var courseImageView: UIImageView!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var lecturesCountLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var idVerificationView: UIView!
    @IBOutlet weak var joinCourseView: UIView!
    @IBOutlet weak var joinCourseSubtitle: UILabel!
    @IBOutlet weak var courseCodeTF: UITextField!
    @IBOutlet weak var courseCodeView: UIView!
    @IBOutlet weak var joinCourseButton: UIButton!
    @IBOutlet weak var chevronExpandImageView: UIImageView!
    @IBOutlet weak var itemsTVView: UIView!
    @IBOutlet weak var itemsTV: UITableView!
    @IBOutlet weak var itemsTVHeight: NSLayoutConstraint!
    @IBOutlet weak var announcementLabel: UILabel!
    @IBOutlet weak var announcementHeight: NSLayoutConstraint!
    @IBOutlet weak var announcementView: UIView!
    
    var didTapExpand: (() -> ())?
    var didTapExpandCollection: ((_ collectionIndex: Int) -> ())?
    var onFreeCoursePurchase: (() -> ())?
    var didTapPurchase: ((_ code: String?) -> ())?
    var didTapLecture: ((CourseCollectionContent.Lecture) -> ())?
    var didTapIDVerification: (() -> ())?
    
    var myCourseModel: MyCourseModel?
    var teacherCourse: TeacherCourseResponseModel.Courses?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        courseCodeTF.delegate = self
        courseCodeTF.attributedPlaceholder = NSAttributedString(
            string: "أدخل رمز التسجيل هنا",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.Gray_400]
        )
        
        setJoinButtonState(isEnabled: false)
        
        itemsTV.delegate = self
        itemsTV.dataSource = self
        itemsTV.register(ExpandableCourseChapterTVCell.nib, forCellReuseIdentifier: ExpandableCourseChapterTVCell.identifier)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func configure(_ myCourseModel: MyCourseModel) {
        self.myCourseModel = myCourseModel
        
        // Image and labels
        courseImageView.kf.setImage(with: URL(string: myCourseModel.imageURL ?? ""), options: [.transition(.fade(0.3))])
        courseNameLabel.text = myCourseModel.name
        setCoursesVideoCountLabel(myCourseModel.videosCount)
        setAnnouncementLabel(myCourseModel.announcement)
        itemsTVView.isUserInteractionEnabled = !(myCourseModel.idVerificationNeeded ?? false)
        itemsTVView.alpha = (myCourseModel.idVerificationNeeded ?? false) ? 0.4 : 1

        
        // Hide course code view if it's free
        if myCourseModel.free == true {
            joinCourseSubtitle.text = "اضغط على الزر التالي للانضمام إلى الدورة."
            courseCodeView.isHidden = true
            setJoinButtonState(isEnabled: true)
        } else {
            joinCourseSubtitle.text = "هل لديك رمز تسجيل؟ أدخله هنا للانضمام مباشرة إلى الدورة التعليمية الخاصة بك."
            courseCodeView.isHidden = false
            setJoinButtonState(isEnabled: false)
        }
        
        // Expansion logic...
        if myCourseModel.isExpanded {
            joinCourseView.isHidden = (myCourseModel.purchased ?? false)
            itemsTVView.isHidden = !(myCourseModel.purchased ?? false)
            announcementView.isHidden = !(myCourseModel.purchased == true && myCourseModel.idVerificationNeeded != true)
            idVerificationView.isHidden = !(myCourseModel.purchased == true && myCourseModel.idVerificationNeeded == true)
            chevronExpandImageView.image = .init(systemName: "chevron.down")
        } else {
            joinCourseView.isHidden = true
            itemsTVView.isHidden = true
            announcementView.isHidden = true
            idVerificationView.isHidden = true
            chevronExpandImageView.image = .init(systemName: "chevron.up")
        }
        
        if let collections = myCourseModel.collections {
            var height = CGFloat(collections.count) * 85
            for collection in collections {
                if collection.isExpanded {
                    height += CGFloat(collection.lectures.count) * 75
                }
            }
            itemsTVHeight.constant = height
        } else {
            itemsTVHeight.constant = 0
        }
        itemsTV.reloadData()
    }
    
    func configure(_ teacherCourse: TeacherCourseResponseModel.Courses) {
        self.teacherCourse = teacherCourse
        
        // Image and labels
        courseImageView.kf.setImage(with: URL(string: teacherCourse.imageURL ?? ""), options: [.transition(.fade(0.3))])
        courseNameLabel.text = teacherCourse.name
        setCoursesVideoCountLabel(teacherCourse.videosCount)
        setAnnouncementLabel(teacherCourse.announcement)
        itemsTVView.isUserInteractionEnabled = !(teacherCourse.idVerificationNeeded ?? false)
        itemsTVView.alpha = (teacherCourse.idVerificationNeeded ?? false) ? 0.4 : 1
        
        // Hide course code view if it's free
        if teacherCourse.free == true {
            joinCourseSubtitle.text = "اضغط على الزر التالي للانضمام إلى الدورة."
            courseCodeView.isHidden = true
            setJoinButtonState(isEnabled: true)
        } else {
            joinCourseSubtitle.text = "هل لديك رمز تسجيل؟ أدخله هنا للانضمام مباشرة إلى الدورة التعليمية الخاصة بك."
            courseCodeView.isHidden = false
            setJoinButtonState(isEnabled: false)
        }
        
        // Expansion logic...
        if teacherCourse.isExpanded {
            joinCourseView.isHidden = (teacherCourse.purchased ?? false)
            itemsTVView.isHidden = !(teacherCourse.purchased ?? false)
            announcementView.isHidden = !(teacherCourse.purchased == true && teacherCourse.idVerificationNeeded != true)
            idVerificationView.isHidden = !(teacherCourse.purchased == true && teacherCourse.idVerificationNeeded == true)
            chevronExpandImageView.image = .init(systemName: "chevron.down")
        } else {
            joinCourseView.isHidden = true
            itemsTVView.isHidden = true
            announcementView.isHidden = true
            idVerificationView.isHidden = true
            chevronExpandImageView.image = .init(systemName: "chevron.up")
        }
        
        if let collections = teacherCourse.collections {
            var height = CGFloat(collections.count) * 85
            for collection in collections {
                if collection.isExpanded {
                    height += CGFloat(collection.lectures.count) * 75
                }
            }
            itemsTVHeight.constant = height
        } else {
            itemsTVHeight.constant = 0
        }
        itemsTV.reloadData()
    }
    
    private func setJoinButtonState(isEnabled: Bool) {
        joinCourseButton.titleLabel?.font = UIFont.rubikFont(weight: .medium, size: 16)
        joinCourseButton.backgroundColor = isEnabled ? .Blue_Brand_500 : .Gray_100
        joinCourseButton.setTitleColor(isEnabled ? .white : .Gray_300, for: .normal)
        joinCourseButton.isUserInteractionEnabled = isEnabled
    }
    
    private func setAnnouncementLabel(_ announcement: String?) {
        if let announcement = announcement {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .right
            paragraphStyle.lineSpacing = 8
            let attributedString = NSAttributedString(
                string: announcement,
                attributes: [
                    .font: UIFont.rubikFont(weight: .regular, size: 14),
                    .paragraphStyle: paragraphStyle
                ]
            )
            announcementLabel.attributedText = attributedString
            announcementHeight.constant = heightForAttributedString(attributedString, width: UIScreen.main.bounds.width - 48 - 32) + 30
        } else {
            announcementLabel.attributedText = nil
            announcementHeight.constant = 0
        }
    }
    
    private func setCoursesVideoCountLabel(_ videosCount: Int?) {
        if let lecturesCount = videosCount {
            switch lecturesCount {
            case 0:
                lecturesCountLabel.text = "لا يوجد محاضرات"
            case 1:
                lecturesCountLabel.text = "محاضرة واحدة"
            case 2:
                lecturesCountLabel.text = "محاضرتين"
            case 3, 4, 5, 6, 7, 8, 9, 10:
                lecturesCountLabel.text = "\(lecturesCount) محاضرات"
            default:
                lecturesCountLabel.text = "\(lecturesCount) محاضرة"
            }
        } else {
            lecturesCountLabel.text = "لا يوجد محاضرات"
        }
    }
    
    @IBAction func expandTapped(_ sender: UIButton) {
        didTapExpand?()
    }
    
    private func heightForString(_ text: String, font: UIFont, width: CGFloat, attributes: [NSAttributedString.Key : Any]) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        return ceil(boundingBox.height)
    }
    
    private func heightForAttributedString(_ attrString: NSAttributedString, width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        
        let boundingBox = attrString.boundingRect(
            with: constraintRect,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        return ceil(boundingBox.height)
    }
    
    @IBAction func joinCourseTapped(_ sender: UIButton) {
        if teacherCourse?.free == true {
            onFreeCoursePurchase?()
        } else {
            didTapPurchase?(courseCodeTF.text)
        }
    }
    
    @IBAction func verifyIDTapped(_ sender: UIButton) {
        didTapIDVerification?()
    }
    
}

extension ExpandableCourseTVCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let myCourseModel = self.myCourseModel {
            return myCourseModel.collections?.count ?? 0
        }
        if let teacherCourse = self.teacherCourse {
            return teacherCourse.collections?.count ?? 0
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let myCourseModel = self.myCourseModel {
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpandableCourseChapterTVCell.identifier, for: indexPath) as! ExpandableCourseChapterTVCell
            cell.configureCollection(myCourseModel.collections?[indexPath.row])
            cell.didTapExpandCollection = { [weak self] in
                guard let self = self else { return }
                didTapExpandCollection?(indexPath.row)
                tableView.reloadData()
            }
            cell.didTapLecture = { [weak self] lecture in
                guard let self = self else { return }
                self.didTapLecture?(lecture)
            }
            return cell
        }
        if let teacherCourse = self.teacherCourse {
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpandableCourseChapterTVCell.identifier, for: indexPath) as! ExpandableCourseChapterTVCell
            cell.configureCollection(teacherCourse.collections?[indexPath.row])
            cell.didTapExpandCollection = { [weak self] in
                guard let self = self else { return }
                didTapExpandCollection?(indexPath.row)
                tableView.reloadData()
            }
            cell.didTapLecture = { [weak self] lecture in
                guard let self = self else { return }
                self.didTapLecture?(lecture)
            }
            return cell
        }
        
        return UITableViewCell()
    }
    
    
}

extension ExpandableCourseTVCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.courseCodeView.layer.borderColor = UIColor.Blue_Brand_500.cgColor
            self.courseCodeView.backgroundColor = .white
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            self.courseCodeView.layer.borderColor = UIColor.Gray_100.cgColor
            self.courseCodeView.backgroundColor = .Gray_25
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let currentText = textField.text,
           let textRange = Range(range, in: currentText) {
            
            let updatedText = currentText.replacingCharacters(in: textRange, with: string)
            let isEmpty = updatedText.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "").isEmpty
            UIView.animate(withDuration: 0.2) {
                self.setJoinButtonState(isEnabled: !isEmpty)
            }
        }
        
        return true
    }
}
