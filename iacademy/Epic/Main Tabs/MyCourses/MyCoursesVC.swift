//
//  MyCoursesVC.swift
//  iacademy
//
//  Created by Marwan Osama on 15/12/2025.
//

import UIKit
import CRRefresh

class MyCoursesVC: UIViewController {

    @IBOutlet weak var itemsTV: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    private let viewModel = MyCoursesViewModel()
    private let loadingView = LoadingView()
    
    private var myCourses = [MyCourseModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        setupUI()
        viewModel.fetchMyCourses()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAccountVerifiedNotification(_:)),
                                               name: Notification.Name("National ID Verified"), object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        
        viewModel.didReceiveCourses = { [weak self] courses in
            guard let self = self else { return }
            itemsTV.cr.endHeaderRefresh()
            emptyLabel.isHidden = !courses.isEmpty
            myCourses = courses
            itemsTV.reloadData()
        }
        
        viewModel.didReceiveCollection = { [weak self] courseID, collectionID, lectures in
            guard let self = self else { return }
            if let courseIndex = myCourses.firstIndex(where: { $0.id == courseID }), let collectionIndex = myCourses[courseIndex].collections?.firstIndex(where: { $0.id == collectionID }) {
                myCourses[courseIndex].collections?[collectionIndex].lectures = lectures
            }
            itemsTV.reloadData()
        }
    }


    private func setupUI() {
        loadingView.setup(in: view)
        emptyLabel.isHidden = true
        itemsTV.delegate = self
        itemsTV.dataSource = self
        itemsTV.register(CoursesTVCell.nib, forCellReuseIdentifier: CoursesTVCell.identifier)
        itemsTV.register(ExpandableCourseTVCell.nib, forCellReuseIdentifier: ExpandableCourseTVCell.identifier)
        itemsTV.cr.addHeadRefresh(animator: FastAnimator()) { [weak self] in
            guard let self = self else { return }
            viewModel.fetchMyCourses(showLoading: false)
        }
    }
    
    @objc func handleAccountVerifiedNotification(_ notification: Notification) {
        viewModel.fetchMyCourses()
    }

}

extension MyCoursesVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myCourses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExpandableCourseTVCell.identifier, for: indexPath) as! ExpandableCourseTVCell
        cell.configure(myCourses[indexPath.row])
        cell.didTapExpand = { [weak self] in
            guard let self = self else { return }
            myCourses[indexPath.row].isExpanded.toggle()
            tableView.reloadData()
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
            self.myCourses[indexPath.row].collections?[collectionIndex].isExpanded.toggle()
            tableView.reloadData()
            let collection = self.myCourses[indexPath.row].collections?[collectionIndex]
            if (collection?.lectures ?? []).isEmpty, (collection?.isExpanded ?? false) {
                if let courseID = myCourses[indexPath.row].id, let collectionID = myCourses[indexPath.row].collections?[collectionIndex].id {
                    viewModel.fetchCourseCollection(courseID: courseID, collectionID: collectionID)
                }
            }

        }

        return cell
        
    }

    
}

