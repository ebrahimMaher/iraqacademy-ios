//
//  CourseVideoCVCell.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import UIKit

class CourseVideoCVCell: UICollectionViewCell {
    
    
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var staticPlayCircleImageView: UIImageView!
    
    var didTapPlay: (() -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
            
        staticPlayCircleImageView.transform = .init(scaleX: -1, y: 1)
        
    }

    @IBAction func playTapped(_ sender: UIButton) {
        didTapPlay?()
    }
    
}

