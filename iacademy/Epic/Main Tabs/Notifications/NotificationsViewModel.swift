//
//  NotificationsViewModel.swift
//  iacademy
//
//  Created by Marwan Osama on 15/12/2025.
//

import Foundation

class NotificationsViewModel {
    
    var didReceiveLoading: ((Bool) -> ())?
    var didReceiveError: ((String) -> ())?
    var didReceiveNotifications: (() -> ())?

    var currentPage = 1
    var totalCount = -1
    var isLoadingMore = false

    var notifications: [NotificationsResponseModel.Notifications] = .init()
    
    func fetchMyNotifications() {
        guard !isLoadingMore else { return }
        guard totalCount == -1 || totalCount > notifications.count else { return }
        isLoadingMore = true
        if currentPage == 1 { didReceiveLoading?(true) }
        NetworkClient.shared.request(api: .notifications, modelType: NotificationsResponseModel.self) { [weak self] result in
            guard let self = self else { return }
            didReceiveLoading?(false)
            isLoadingMore = false
            switch result {
            case .success(let notificationsResponseModel):
                if notifications.isEmpty {
                    notifications = notificationsResponseModel.data ?? []
                } else {
                    notifications.append(contentsOf: notificationsResponseModel.data ?? [])
                }
                if let totalCount = notificationsResponseModel.meta?.total {
                    self.totalCount = totalCount
                    self.currentPage += 1
                }
                didReceiveNotifications?()
            case .failure(let error):
                didReceiveError?(error.description)
            }
        }
    }
    
    func initPages() {
        currentPage = 1
        totalCount = -1
        notifications = []
    }
    
}
