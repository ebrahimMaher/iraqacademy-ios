//
//  ResetPasswordVC.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import UIKit
import FittedSheets
import SafariServices

class ResetPasswordVC: UIViewController {
    
    
    @IBOutlet weak var countryFlagImageView: UIImageView!
    @IBOutlet weak var countryPhoneCodeLabel: UILabel!
    
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var phoneView: UIView!

    var safariVC: SFSafariViewController?

    private let loadingView = LoadingView()
    private let viewModel = ResetPasswordViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        setupUI()
        setupDefaultCountry()
    }
    
    private func setupUI() {
        loadingView.setup(in: view)
        
        phoneTF.delegate = self
        phoneTF.attributedPlaceholder = NSAttributedString(
            string: "أدخل رقم الهاتف",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.Gray_400]
        )
        phoneTF.text = "0"
        countryPhoneCodeLabel.adjustsFontSizeToFitWidth = true

    }
    
    private func bind() {
        viewModel.didReceiveLoading = { [weak self] loading in
            guard let self = self else { return }
            loadingView.isHidden = !loading
        }
        
        viewModel.didReceiveError = { [weak self] error in
            guard let self = self else { return }
            showSimpleAlert(title: "خطأ", message: error)
        }
        
        viewModel.didReceiveValidationError = { [weak self] error, isMoreThanOneError in
            guard let self = self else { return }
            isMoreThanOneError ? showRightAlignedAlert(title: "خطأ في التحقق", message: error) : showSimpleAlert(title: "خطأ في التحقق", message: error)
        }
        
        viewModel.didReceiveSuccess = { [weak self] url in
            guard let self = self else { return }
            beginTelegramVerification(link: url)
        }
    }
    
    private func setupDefaultCountry() {
        let defaultCountry = CountryInfo(countryCode: "IQ", phoneCode: "+964", arabicName: "العراق")
        if let url = URL(string: "https://flagcdn.com/w80/\(defaultCountry.countryCode.lowercased()).png") {
            countryFlagImageView.kf.indicatorType = .activity
            countryFlagImageView.kf.setImage(with: url, options: [.transition(.fade(0.3)), .cacheMemoryOnly])
        }
        countryPhoneCodeLabel.text = defaultCountry.phoneCode
        viewModel.phoneCode = defaultCountry.phoneCode

    }
    
    private func beginTelegramVerification(link: String) {
        if let url = URL(string: link) {
            let safariVC = SFSafariViewController(url: url)
            safariVC.delegate = self
            self.safariVC = safariVC
            present(safariVC, animated: true)
        }
    }
    
    @IBAction func countryTapped(_ sender: UIButton) {
        let vc = PhoneCodesListVC()
        vc.didSelectCountry = { [weak self] country in
            guard let self = self else { return }
            if let url = URL(string: "https://flagcdn.com/w80/\(country.countryCode.lowercased()).png") {
                countryFlagImageView.kf.indicatorType = .activity
                countryFlagImageView.kf.setImage(with: url, options: [.transition(.fade(0.3)), .cacheMemoryOnly])
            }
            countryPhoneCodeLabel.text = country.phoneCode
            viewModel.phoneCode = country.phoneCode
        }
        let sheetVC = SheetViewController(controller: vc, sizes: [.fixed(UIScreen.main.bounds.height * 0.8)])
        sheetVC.handleColor = .clear
        sheetVC.dismissOnBackgroundTap = true
        sheetVC.topCornersRadius = 20
        self.present(sheetVC, animated: true)

    }


    @IBAction func sendOTPTapped(_ sender: UIButton) {
        viewModel.resetPassword(phone: phoneTF.text ?? "")
    }
    
}

extension ResetPasswordVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.phoneView.backgroundColor = .white
            self.phoneView.layer.borderColor = UIColor.Blue_Brand_500.cgColor
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.phoneView.backgroundColor = .Gray_50
            self.phoneView.layer.borderColor = UIColor.gray100.cgColor
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == phoneTF else { return true }
        
        let currentText = textField.text ?? ""
        let nsText = currentText as NSString
        let newText = nsText.replacingCharacters(in: range, with: string)
        
        if range.location == 0 && range.length > 0 {
            return false
        }
        
        if !newText.hasPrefix("0") {
            textField.text = "0" + newText.filter { $0.isNumber && $0 != "0" }
            return false
        }
        
        return true
    }

    
}

extension ResetPasswordVC: SFSafariViewControllerDelegate {
    
    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        print("Safari activityItemsFor \(URL.absoluteString) - title \(title)")
        return []
    }
    
    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        print("Safari initialLoadDidRedirectTo \(URL.absoluteString)")
    }
}

