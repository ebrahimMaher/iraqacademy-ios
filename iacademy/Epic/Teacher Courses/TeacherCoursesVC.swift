//
//  TeacherCoursesVC.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import UIKit
import CRRefresh

class TeacherCoursesVC: UIViewController {
    
    @IBOutlet weak var navigationHeader: NavigationHeader!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var itemsTV: UITableView!
    
    var teacherID: String?
    var teacherName: String?
    
    private let viewModel = TeacherCoursesViewModel()
    private let loadingView = LoadingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        setupUI()
        viewModel.fetchTeacherCourses(id: teacherID)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAccountVerifiedNotification(_:)),
                                               name: Notification.Name("National ID Verified"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        loadingView.setup(in: view)
        navigationHeader.title = teacherName ?? "المدرس"
        contentView.isHidden = true
        emptyLabel.isHidden = true
        
        itemsTV.delegate = self
        itemsTV.dataSource = self
        itemsTV.register(CoursesTVCell.nib, forCellReuseIdentifier: CoursesTVCell.identifier)
        itemsTV.register(ExpandableCourseTVCell.nib, forCellReuseIdentifier: ExpandableCourseTVCell.identifier)
        itemsTV.cr.addHeadRefresh(animator: FastAnimator()) { [weak self] in
            guard let self = self else { return }
            viewModel.initPages()
            viewModel.fetchTeacherCourses(id: teacherID)
        }
    }
    
    private func bind() {
        viewModel.didReceiveError = { [weak self] error in
            guard let self = self else { return }
            showSimpleAlert(title: "خطأ", message: error)
        }
        
        viewModel.didReceiveLoading = { [weak self] loading in
            guard let self = self else { return }
            loadingView.isHidden = !loading
        }
        
        viewModel.didReceiveCourses = { [weak self] in
            guard let self = self else { return }
            contentView.isHidden = false
            emptyLabel.isHidden = !viewModel.teacherCourses.isEmpty
            itemsTV.cr.endHeaderRefresh()
            itemsTV.reloadData()
        }
        
        viewModel.didPurchaseCourseSuccessfully = { [weak self] in
            guard let self = self else { return }
            itemsTV.reloadData()
        }
        
        viewModel.didReceiveCollection = { [weak self] courseID, collectionID, lectures in
            guard let self = self else { return }
            if let courseIndex = viewModel.teacherCourses.firstIndex(where: { $0.id == courseID }), let collectionIndex = viewModel.teacherCourses[courseIndex].collections?.firstIndex(where: { $0.id == collectionID }) {
                viewModel.teacherCourses[courseIndex].collections?[collectionIndex].lectures = lectures
            }
            itemsTV.reloadData()
        }
    }
    
    @objc func handleAccountVerifiedNotification(_ notification: Notification) {
        viewModel.fetchTeacherCourses(id: teacherID)
    }
}

extension TeacherCoursesVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.teacherCourses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExpandableCourseTVCell.identifier, for: indexPath) as! ExpandableCourseTVCell
        cell.configure(viewModel.teacherCourses[indexPath.row])
        cell.didTapExpand = { [weak self] in
            guard let self = self else { return }
            viewModel.teacherCourses[indexPath.row].isExpanded.toggle()
            tableView.reloadData()
        }
        
        cell.didTapPurchase = { [weak self] code in
            guard let self = self else { return }
            viewModel.purchaseCourse(courseID: viewModel.teacherCourses[indexPath.row].id, code: code)
        }
        
        cell.onFreeCoursePurchase = { [weak self] in
            guard let self = self else { return }
            viewModel.purchaseFreeCourse(courseID: viewModel.teacherCourses[indexPath.row].id)
        }
        
        cell.didTapLecture = { [weak self] lecture in
            guard let self = self,
                  let lectureID = lecture.id,
                  let lectureName = lecture.name else { return }
            AppCoordinator.shared.navigate(to: .lecturesDetails(lectureID: lectureID, lectureName: lectureName))
        }
        
        cell.didTapIDVerification = { [weak self] in
            guard let self else { return }
            AppCoordinator.shared.navigate(to: .idVerification)
        }
        
        cell.didTapExpandCollection = { [weak self] collectionIndex in
            guard let self = self else { return }
            self.viewModel.teacherCourses[indexPath.row].collections?[collectionIndex].isExpanded.toggle()
            tableView.reloadData()
            let collection = self.viewModel.teacherCourses[indexPath.row].collections?[collectionIndex]
            if (collection?.lectures ?? []).isEmpty, (collection?.isExpanded ?? false) {
                if let courseID = viewModel.teacherCourses[indexPath.row].id, let collectionID = viewModel.teacherCourses[indexPath.row].collections?[collectionIndex].id {
                    viewModel.fetchCourseCollection(courseID: courseID, collectionID: collectionID)
                }
            }

        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.teacherCourses.count - 1 {
            viewModel.fetchTeacherCourses(id: teacherID)
        }
    }
    
}
