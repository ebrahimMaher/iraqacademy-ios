//
//  PhoneCodesListTVCell.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import UIKit
import Kingfisher

class PhoneCodesListTVCell: UITableViewCell {

    @IBOutlet weak var countryFlagImageView: UIImageView!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var phoneCodeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configureCell(_ country: CountryInfo) {
        if let url = URL(string: "https://flagcdn.com/w80/\(country.countryCode.lowercased()).png") {
            countryFlagImageView.kf.indicatorType = .activity
            countryFlagImageView.kf.setImage(with: url, options: [.transition(.fade(0.3)), .cacheMemoryOnly])
        }
        countryLabel.text = country.arabicName
        phoneCodeLabel.text = country.phoneCode
    }
    
    func configureCellForEmptyState() {
        countryFlagImageView.image = nil
        countryLabel.text = "لا يوجد عناصر مطابقة"
        phoneCodeLabel.text = nil
    }
    
    
}
