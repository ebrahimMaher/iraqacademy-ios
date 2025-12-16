//
//  CourseVideoTVCell.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import UIKit
import AVKit

class CourseVideoTVCell: UITableViewCell {
    
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var staticPlayCircleImageView: UIImageView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var videoNumberLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        staticPlayCircleImageView.transform = .init(scaleX: -1, y: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(_ lecutre: LectureDetailsVideo, index: Int) {
        videoTitleLabel.text = lecutre.name
        videoNumberLabel.text = "\(index+1)"
        if let duration = lecutre.duration {
            durationLabel.text = convertTimeString(duration)
        } else {
            durationLabel.text = ""
        }
    }
    
    func convertTimeString(_ timeString: String) -> String {
        let arabicFormatter = NumberFormatter()
        arabicFormatter.locale = Locale(identifier: "ar")
        arabicFormatter.numberStyle = .decimal
        
        var hours = 0
        var minutes = 0
        
        if timeString.components(separatedBy: ":").count == 2 {
            // Format: "10:00" → treat as minutes
            if let min = Int(timeString.components(separatedBy: ":")[0]) {
                minutes = min
            }
        } else if timeString.components(separatedBy: ":").count == 3 {
            // Format: "2:10:00" → treat as hours:minutes:seconds
            let components = timeString.components(separatedBy: ":")
            if let hr = Int(components[0]) {
                hours = hr
            }
            if let min = Int(components[1]) {
                minutes = min
            }
        }
        
        var result = ""
        
        if hours > 0 {
            let hrStr = arabicFormatter.string(from: NSNumber(value: hours)) ?? "\(hours)"
            result += "\(hrStr)س"
        }
        
        if minutes > 0 || (hours == 0 && minutes == 0) {
            let minStr = arabicFormatter.string(from: NSNumber(value: minutes)) ?? "\(minutes)"
            if !result.isEmpty {
                result += " "
            }
            result += "\(minStr)د"
        }
        
        return result
    }
        
}
