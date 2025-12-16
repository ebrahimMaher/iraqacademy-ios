//
//  ExpandableCourseChapterTVCell.swift
//  iacademy
//
//  Created by Marwan Osama on 15/12/2025.
//

import UIKit

class ExpandableCourseChapterTVCell: UITableViewCell {

    @IBOutlet weak var chapterNameLabel: UILabel!
    @IBOutlet weak var videosCountLabel: UILabel!
    @IBOutlet weak var itemsTV: UITableView!
    @IBOutlet weak var itemsTVHeight: NSLayoutConstraint!
    @IBOutlet weak var chevronExpandImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var stackView: UIStackView!
    
    
    var collection: CourseCollectionModel?
    
    var didTapExpandCollection: (() -> ())?
    var didTapLecture: ((CourseCollectionContent.Lecture) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        itemsTV.delegate = self
        itemsTV.dataSource = self
        itemsTV.register(CollectionCoursesTVCell.nib, forCellReuseIdentifier: CollectionCoursesTVCell.identifier)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(_ lecture: MyCourseLecture?) {
        chapterNameLabel.text = lecture?.name
        setCoursesVideoCountLabel(lecture?.videosCount)
    }
    
    func configure(_ lecture: TeacherCourseResponseModel.Lecture?) {
        chapterNameLabel.text = lecture?.name
        setCoursesVideoCountLabel(lecture?.videosCount)

    }
    
    func configureCollection(_ collection: CourseCollectionModel?) {
        activityIndicator.startAnimating()
        chapterNameLabel.text = collection?.name ?? ""
        setCoursesVideoCountLabel(collection?.lecturesCount)
        self.collection = collection
        itemsTV.reloadData()
        if collection?.isExpanded ?? false {
            if (collection?.lectures ?? []).isEmpty {
                activityIndicator.isHidden = false
                chevronExpandImageView.isHidden = true
                itemsTV.isHidden = true
                itemsTVHeight.constant = 0
            } else {
                activityIndicator.isHidden = true
                chevronExpandImageView.isHidden = false
                chevronExpandImageView.image = .init(systemName: "chevron.up")
                itemsTV.isHidden = false
                itemsTVHeight.constant = CGFloat(collection?.lectures.count ?? 0) * 70
            }
        } else {
            activityIndicator.isHidden = true
            chevronExpandImageView.isHidden = false
            chevronExpandImageView.image = .init(systemName: "chevron.down")
            itemsTV.isHidden = true
            itemsTVHeight.constant = 0
        }
    }
    
    private func setCoursesVideoCountLabel(_ videosCount: Int?) {
        if let lecturesCount = videosCount {
            switch lecturesCount {
            case 0:
                videosCountLabel.text = "لا يوجد محاضرات"
            case 1:
                videosCountLabel.text = "محاضرة واحدة"
            case 2:
                videosCountLabel.text = "محاضرتين"
            case 3, 4, 5, 6, 7, 8, 9, 10:
                videosCountLabel.text = "\(lecturesCount) محاضرات"
            default:
                videosCountLabel.text = "\(lecturesCount) محاضرة"
            }
        } else {
            videosCountLabel.text = "لا يوجد محاضرات"
        }
    }
    
    
    @IBAction func expandCollapseTapped(_ sender: UIButton) {
        didTapExpandCollection?()
    }
    
}

extension ExpandableCourseChapterTVCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (collection?.lectures ?? []).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CollectionCoursesTVCell.identifier, for: indexPath) as! CollectionCoursesTVCell
        cell.chapterNameLabel.text = collection?.lectures[safe: indexPath.row]?.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let lecture = collection?.lectures[safe: indexPath.row] {
            didTapLecture?(lecture)
        }
    }
    
}

