//
//  CourseDetailsViewModel.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import Foundation

class CourseDetailsViewModel {
    
    var didReceiveError: ((String) -> ())?
    var didReceiveLoading: ((Bool) -> ())?
    var didReceiveCourseDetails: ((CourseDetailsModel) -> ())?
    var didPurchaseCourseSuccessfully: (() -> ())?
    
    var courseID: Int?
    
    func fetchCourseDetails(id: Int?) {
        guard let id = id else { return }
        self.courseID = id
        didReceiveLoading?(true)
        NetworkClient.shared.request(api: .courseDetails(id: id), modelType: CourseDetailsResponseModel.self) { [weak self] result in
            guard let self = self else { return }
            didReceiveLoading?(false)
            switch result {
            case .success(let courseDetailsResponseModel):
                if let courseDetails = courseDetailsResponseModel.data { didReceiveCourseDetails?(courseDetails) }
            case .failure(let error):
                didReceiveError?(error.description)
            }
        }
    }
    
    func purchaseCourse(code: String) {
        didReceiveLoading?(true)
        NetworkClient.shared.request(api: .purchaseCourse(code: code), modelType: PurchaseCourseResponseModel.self) { [weak self] result in
            guard let self = self else { return }
            didReceiveLoading?(false)
            switch result {
            case .success(let purchaseCourseResponse):
                if let purchasedCourse = purchaseCourseResponse.data { didPurchaseCourseSuccessfully?() }
            case .failure(let error):
                didReceiveError?(error.description)
            }
        }
    }
    
}
