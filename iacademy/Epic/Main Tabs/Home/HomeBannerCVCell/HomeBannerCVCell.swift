//
//  HomeBannerCVCell.swift
//  iacademy
//
//  Created by Marwan Osama on 15/12/2025.
//

import UIKit
import Kingfisher

class HomeBannerCVCell: UICollectionViewCell {

    @IBOutlet weak var bannerImageView: UIImageView!


    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    func configure(_ banner: HomeBannerModel) {
        bannerImageView.kf.indicatorType = .activity
        bannerImageView.kf.setImage(with: URL(string: (banner.url ?? "")), options: [.transition(.fade(0.5)), .cacheMemoryOnly])
    }
    
    
    
}

