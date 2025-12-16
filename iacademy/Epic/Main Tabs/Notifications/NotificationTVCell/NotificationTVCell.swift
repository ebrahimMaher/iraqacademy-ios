//
//  NotificationTVCell.swift
//  iacademy
//
//  Created by Marwan Osama on 15/12/2025.
//

import UIKit

class NotificationTVCell: UITableViewCell {

    @IBOutlet weak var notificationTitleLabel: UILabel!
    @IBOutlet weak var notificationContentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configure(_ notification: NotificationsResponseModel.Notifications) {
        notificationTitleLabel.text = notification.title
        notificationContentLabel.text = notification.content
    }
    
}
