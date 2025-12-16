//
//  CourseDetailsVC.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import UIKit
import Kingfisher

class CourseDetailsVC: UIViewController {

    @IBOutlet weak var teacherNameLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var courseImageView: UIImageView!
    @IBOutlet weak var navigationHeader: NavigationHeader!
    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var courseVideoCountLabel: UILabel!
    @IBOutlet weak var chaptersCountLabel: UILabel!
    @IBOutlet weak var itemsTV: UITableView!
    
    @IBOutlet weak var joinCourseView: UIView!
    @IBOutlet weak var courseCodeView: UIView!
    @IBOutlet weak var courseCodeTF: UITextField!
    @IBOutlet weak var joinCourseButton: UIButton!

    
    private let loadingView = LoadingView()
    private let viewModel = CourseDetailsViewModel()
    
    var courseID: Int?
    
    private var lectures: [CourseDetailsLecture] = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        setupUI()
        viewModel.fetchCourseDetails(id: courseID)
    }

    private func setupUI() {
        
        loadingView.setup(in: view)
        contentView.isHidden = true
        
        joinCourseView.isHidden = true
        courseCodeTF.delegate = self
        courseCodeTF.attributedPlaceholder = NSAttributedString(
            string: "أدخل رمز التسجيل هنا",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.Gray_400]
        )
        joinCourseButton.backgroundColor = .Gray_100
        joinCourseButton.setTitleColor(.Gray_300, for: .normal)
        joinCourseButton.isUserInteractionEnabled = false


        itemsTV.isHidden = true
        itemsTV.delegate = self
        itemsTV.dataSource = self
        itemsTV.register(CourseLecturesTVCell.nib, forCellReuseIdentifier: CourseLecturesTVCell.identifier)

    }
    
    func bind() {
        viewModel.didReceiveError = { [weak self] error in
            guard let self = self else { return }
            showSimpleAlert(title: "خطأ", message: error)
        }
        
        viewModel.didReceiveLoading = { [weak self] loading in
            guard let self = self else { return }
            loadingView.isHidden = !loading
        }
        
        viewModel.didReceiveCourseDetails = { [weak self] courseDetails in
            guard let self = self else { return }
            setupCourseDetails(courseDetails)
        }
        
        viewModel.didPurchaseCourseSuccessfully = { [weak self] in
            guard let self = self else { return }
            viewModel.fetchCourseDetails(id: courseID)
        }
    }
    
    private func setupCourseDetails(_ courseDetails: CourseDetailsModel) {
        contentView.isHidden = false
        itemsTV.isHidden = (courseDetails.purchased ?? false) ? false : true
        joinCourseView.isHidden = (courseDetails.purchased ?? false) ? true : false
        courseImageView.kf.setImage(with: URL(string: courseDetails.imageURL ?? ""), options: [.transition(.fade(0.3)), .cacheMemoryOnly])
        setCoursesLecutresCountLabel(courseDetails)
        setCoursesVideoCountLabel(courseDetails)
        teacherNameLabel.text = courseDetails.teacher?.name
        navigationHeader.title = courseDetails.name ?? "الدورة"
        courseNameLabel.text = courseDetails.name
        lectures = courseDetails.lectures ?? []
        itemsTV.reloadData()
        
    }
    
    private func setCoursesLecutresCountLabel(_ courseDetails: CourseDetailsModel) {
        if let lecturesCount = courseDetails.lecturesCount {
            switch lecturesCount {
            case 3, 4, 5, 6, 7, 8, 9, 10:
                chaptersCountLabel.text = "\(lecturesCount) فصول"
            case 0:
                chaptersCountLabel.text = "لا يوجد فصول"
            case 1:
                chaptersCountLabel.text = "فصل واحدة"
            case 2:
                chaptersCountLabel.text = "فصلين"
            default:
                chaptersCountLabel.text = "\(lecturesCount) فصل"
            }
        } else {
            courseVideoCountLabel.text = "لا يوجد فصول"
        }
    }
    
    private func setCoursesVideoCountLabel(_ courseDetails: CourseDetailsModel) {
        if let lecturesCount = courseDetails.videosCount {
            switch lecturesCount {
            case 0:
                courseVideoCountLabel.text = "لا يوجد محاضرات"
            case 1:
                courseVideoCountLabel.text = "محاضرة واحدة"
            case 2:
                courseVideoCountLabel.text = "محاضرتين"
            case 3, 4, 5, 6, 7, 8, 9, 10:
                courseVideoCountLabel.text = "\(lecturesCount) محاضرات"
            default:
                courseVideoCountLabel.text = "\(lecturesCount) محاضرة"
            }
        } else {
            courseVideoCountLabel.text = "لا يوجد محاضرات"
        }
    }
        
    @IBAction func joinCourseTapped(_ sender: UIButton) {
        let courseCode = courseCodeTF.text ?? ""
        viewModel.purchaseCourse(code: courseCode)
    }


}

extension CourseDetailsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lectures.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CourseLecturesTVCell.identifier, for: indexPath) as! CourseLecturesTVCell
        cell.configure(lectures[indexPath.row])
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let lectureID = lectures[indexPath.row].id,
              let lectureName = lectures[indexPath.row].name else { return }
        AppCoordinator.shared.navigate(to: .lecturesDetails(lectureID: lectureID, lectureName: lectureName))
    }
    
    
}

extension CourseDetailsVC: UITextFieldDelegate {
    
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
                self.joinCourseButton.backgroundColor = isEmpty ? .Gray_100 : .Blue_Brand_500
                self.joinCourseButton.setTitleColor(isEmpty ? .Gray_300 : .white, for: .normal)
                self.joinCourseButton.isUserInteractionEnabled = isEmpty ? false : true
            }
        }
        
        return true
    }
    
}
