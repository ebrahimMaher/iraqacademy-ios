//
//  TeacherCoursesViewModel.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import Foundation


class TeacherCoursesViewModel {
    
    
    var didReceiveError: ((String) -> ())?
    var didReceiveLoading: ((Bool) -> ())?
    var didReceiveCourses: (() -> ())?
    var didPurchaseCourseSuccessfully: (() -> ())?
    var didReceiveCollection: ((_ courseID: String, _ collectionID: String, _ lectures: [CourseCollectionContent.Lecture]) -> ())?


    var teacherCourses: [TeacherCourseResponseModel.Courses] = .init()
    var currentPage = 1
    var totalCount = -1
    var isLoadingMore = false
    
    func fetchTeacherCourses(id: String?) {
        guard let id = id, !isLoadingMore else { return }
        guard totalCount == -1 || totalCount > teacherCourses.count else { return }
        isLoadingMore = true
        if currentPage == 1 { didReceiveLoading?(true) }
        NetworkClient.shared.request(api: .teacherCourses(id: id, page: currentPage), modelType: TeacherCourseResponseModel.self) { [weak self] result in
            guard let self = self else { return }
            didReceiveLoading?(false)
            isLoadingMore = false
            switch result {
            case .success(let teacherCoursesResponse):
                if teacherCourses.isEmpty {
                    teacherCourses = teacherCoursesResponse.data ?? []
                } else {
                    teacherCourses.append(contentsOf: teacherCoursesResponse.data ?? [])
                }
                if let totalCount = teacherCoursesResponse.meta?.total {
                    self.totalCount = totalCount
                    self.currentPage += 1
                }
                didReceiveCourses?()
            case .failure(let error):
                didReceiveError?(error.description)
            }
        }
    }
    
    func fetchCourseCollection(courseID: String, collectionID: String) {
        NetworkClient.shared.request(api: .courseCollectionContent(collectionID: collectionID), modelType: CourseCollectionContent.self) { [weak self] result in
            guard let self = self else { return }
            didReceiveLoading?(false)
            switch result {
            case .success(let courseCollection):
                didReceiveCollection?(courseID, collectionID, courseCollection.lectures ?? [])
            case .failure(let error):
                didReceiveError?(error.description)
            }
        }
    }
    
    func purchaseCourse(courseID: String?, code: String?) {
        guard let courseID = courseID, let code = code else { return }
        didReceiveLoading?(true)
        NetworkClient.shared.request(api: .purchaseSpecificCourse(courseID: courseID, code: code), modelType: PurchaseCourseResponseModel.self) { [weak self] result in
            guard let self = self else { return }
            didReceiveLoading?(false)
            switch result {
            case .success(let purchaseCourseResponse):
                if let purchasedCourse = purchaseCourseResponse.data {
                    if let courseIndex = teacherCourses.firstIndex(where: { $0.id == purchasedCourse.id }) {
                        teacherCourses[courseIndex].purchased = true
                        teacherCourses[courseIndex].collections = (purchasedCourse.collections ?? [])
                    }
                    didPurchaseCourseSuccessfully?()
                }
            case .failure(let error):
                didReceiveError?(error.description)
            }
        }
    }
    
    func purchaseFreeCourse(courseID: String?) {
        guard let courseID = courseID else { return }
        didReceiveLoading?(true)
        NetworkClient.shared.request(api: .purchaseFreeCourse(courseID: courseID), modelType: PurchaseCourseResponseModel.self) { [weak self] result in
            guard let self = self else { return }
            didReceiveLoading?(false)
            switch result {
            case .success(let purchaseCourseResponse):
                if let purchasedCourse = purchaseCourseResponse.data {
                    if let courseIndex = teacherCourses.firstIndex(where: { $0.id == purchasedCourse.id }) {
                        teacherCourses[courseIndex].purchased = true
                        teacherCourses[courseIndex].collections = (purchasedCourse.collections ?? [])
                    }
                    didPurchaseCourseSuccessfully?()
                }
            case .failure(let error):
                didReceiveError?(error.description)
            }
        }
    }
    
    func initPages() {
        currentPage = 1
        totalCount = -1
        teacherCourses = []
    }
}
