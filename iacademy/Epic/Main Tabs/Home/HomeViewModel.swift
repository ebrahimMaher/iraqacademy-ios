//
//  HomeViewModel.swift
//  iacademy
//
//  Created by Marwan Osama on 15/12/2025.
//

import Foundation

class HomeViewModel {
    
    
    var didReceiveError: ((String) -> ())?
    var didReceiveLoading: ((Bool) -> ())?
    var didPurchaseCourseSuccessfully: ((PurchaseCourseModel) -> ())?
    var didReceiveHomeData: ((HomeResponseModel) -> ())?
    
    
    func purchaseCode(code: String) {
        didReceiveLoading?(true)
        NetworkClient.shared.request(api: .purchaseCourse(code: code), modelType: PurchaseCourseResponseModel.self) { [weak self] result in
            guard let self = self else { return }
            didReceiveLoading?(false)
            switch result {
            case .success(let purchaseCourseResponse):
                if let purchasedCourse = purchaseCourseResponse.data { didPurchaseCourseSuccessfully?(purchasedCourse) }
            case .failure(let error):
                didReceiveError?(error.description)
            }
        }
    }
    
    
    func fetchHomeData() {
        didReceiveLoading?(true)
        NetworkClient.shared.request(api: .homeData, modelType: HomeResponseModel.self) { [weak self] result in
            guard let self = self else { return }
            didReceiveLoading?(false)
            switch result {
            case .success(let homeResponseModel):
                didReceiveHomeData?(homeResponseModel)
            case .failure(let error):
                if error != .notAuthorized {
                    didReceiveError?(error.description)
                }
            }
        }
    }
    
    
    func logout() {
        didReceiveLoading?(true)
        NetworkClient.shared.request(api: .logout, modelType: String.self) { [weak self] result in
            guard let self = self else { return }
            didReceiveLoading?(false)
            switch result {
            case .success(let response):
                if response.lowercased() == "true" || response == "1" {
                    CacheClient.shared.clearAll()
                    AppCoordinator.shared.setRoot(to: .login)
                }
            case .failure(let error):
                didReceiveError?(error.description)
            }
        }
    }
}
