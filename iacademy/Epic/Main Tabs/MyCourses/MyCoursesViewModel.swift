//
//  MyCoursesViewModel.swift
//  iacademy
//
//  Created by Marwan Osama on 15/12/2025.
//

import Foundation

class MyCoursesViewModel {
    
    
    var didReceiveLoading: ((Bool) -> ())?
    var didReceiveError: ((String) -> ())?
    var didReceiveCourses: (([MyCourseModel]) -> ())?
    var didReceiveCollection: ((_ courseID: String, _ collectionID: String, _ lectures: [CourseCollectionContent.Lecture]) -> ())?
    
    
    func fetchMyCourses(showLoading: Bool = true) {
        if showLoading { didReceiveLoading?(true) }
        NetworkClient.shared.request(api: .myCourses, modelType: MyCoursesResponseModel.self) { [weak self] result in
            guard let self = self else { return }
            didReceiveLoading?(false)
            switch result {
            case .success(let myCoursesResponseModel):
                didReceiveCourses?(myCoursesResponseModel.data ?? [])
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
    
}
