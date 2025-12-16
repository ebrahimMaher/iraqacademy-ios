//
//  LectureDetailsViewModel.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import Foundation

class LectureDetailsViewModel {
    
    var didReceiveError: ((String) -> ())?
    var didReceiveLoading: ((Bool) -> ())?
    var didReceiveLectureDetails: (([LectureDetailsVideo]) -> ())?
    var didReceiveVideoLink: ((LectureVideoLinkModel) -> ())?
    
    func fetchLectureDetails(id: String?) {
        guard let id = id else { return }
        didReceiveLoading?(true)
        NetworkClient.shared.request(api: .lectureDetails(id: id), modelType: LectureDetailsResponseModel.self) { [weak self] result in
            guard let self = self else { return }
            didReceiveLoading?(false)
            switch result {
            case .success(let lectureDetailsResponseModel):
                if let videos = lectureDetailsResponseModel.videos { didReceiveLectureDetails?(videos) }
            case .failure(let error):
                didReceiveError?(error.description)
            }
        }
    }
    
    func fetchVideoLink(id: String?) {
        guard let id = id else { return }
        didReceiveLoading?(true)
        NetworkClient.shared.request(api: .lectureVideoLink(id: id), modelType: LectureVideoLinkModel.self) { [weak self] result in
            guard let self = self else { return }
            didReceiveLoading?(false)
            switch result {
            case .success(let videoLinkResponse):
                didReceiveVideoLink?(videoLinkResponse)
            case .failure(let error):
                didReceiveError?(error.description)
            }
        }
    }
}
