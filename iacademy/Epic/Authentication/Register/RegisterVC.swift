//
//  RegisterVC.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import UIKit
import FittedSheets
import Kingfisher

class RegisterVC: UIViewController {

    @IBOutlet weak var fullNameView: UIView!
    @IBOutlet weak var fullNameTF: UITextField!
    
    @IBOutlet weak var birthdateTF: UITextField!
    
    @IBOutlet weak var countryFlagImageView: UIImageView!
    @IBOutlet weak var countryPhoneCodeLabel: UILabel!
    
    @IBOutlet weak var specialityTF: UITextField!
    
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var phoneView: UIView!

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var emailView: UIView!
    
    
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var securePasswordButton: UIButton!
    
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var successMessageLabel: UILabel!
    
    
    lazy var serverDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone(abbreviation: "UTC") ?? TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    lazy var displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar_EG")
        formatter.timeZone = TimeZone(abbreviation: "UTC") ?? TimeZone.current
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()
    
    var specialities: [Speciality] = []
    
    private let viewModel = RegisterViewModel()
    private let loadingView = LoadingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        setupUI()
        setupDefaultCountry()
        
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
        
        viewModel.didReceiveRegisterResponse = { [weak self] registerResponseModel in
            guard let self = self else { return }
            handleRegisterResponseModel(registerResponseModel)
        }
    }
    
    private func setupUI() {
        loadingView.setup(in: view)
        [fullNameTF, phoneTF, emailTF, passwordTF].forEach {
            $0?.delegate = self
        }
        fullNameTF.attributedPlaceholder = NSAttributedString(
            string: "أدخل الإسم بالكامل",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.Gray_400]
        )
        birthdateTF.attributedPlaceholder = NSAttributedString(
            string: "اختر تاريخًا",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.Gray_400]
        )
        specialityTF.attributedPlaceholder = NSAttributedString(
            string: "إختيار تخصص",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.Gray_400]
        )
        phoneTF.attributedPlaceholder = NSAttributedString(
            string: "أدخل رقم الهاتف",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.Gray_400]
        )
        emailTF.attributedPlaceholder = NSAttributedString(
            string: "أدخل بريدك الإلكتروني",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.Gray_400]
        )
        passwordTF.attributedPlaceholder = NSAttributedString(
            string: "أدخل كلمة المرور",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.Gray_400]
        )
        specialities = (CacheClient.shared.appInfo?.specialities ?? []).filter { $0.id != nil && $0.name != nil }
        phoneTF.text = "0"
        countryPhoneCodeLabel.adjustsFontSizeToFitWidth = true

    }
    
    private func setupDefaultCountry() {
        let defaultCountry = CountryInfo(countryCode: "IQ", phoneCode: "+964", arabicName: "العراق")
        if let url = URL(string: "https://flagcdn.com/w80/\(defaultCountry.countryCode.lowercased()).png") {
            countryFlagImageView.kf.indicatorType = .activity
            countryFlagImageView.kf.setImage(with: url, options: [.transition(.fade(0.3)), .cacheMemoryOnly])
        }
        countryPhoneCodeLabel.text = defaultCountry.phoneCode
        viewModel.registerRequestModel.country = defaultCountry.countryCode
        viewModel.registerRequestModel.phone_code = defaultCountry.phoneCode

    }
    
    private func togglePasswordVisibility() {
        passwordTF.isSecureTextEntry.toggle()
        securePasswordButton.tintColor = passwordTF.isSecureTextEntry ? .Gray_400 : .Gray_900
    }
    
    private func handleRegisterResponseModel(_ registerResponseModel: RegisterResponseModel) {
        if let message = registerResponseModel.message, !message.isEmpty {
            successMessageLabel.text = message
        }
        successView.isHidden = false
    }
    
    @IBAction func birthdateTapped(_ sender: UIButton) {
        let picker = DatePickerPopup.instance()
        picker.pickerTitle = "تاريخ الميلاد"
        picker.didPickDate = { [weak self] date in
            guard let self = self else { return }
            self.birthdateTF.text = displayFormatter.string(from: date)
            self.viewModel.registerRequestModel.birthdate = serverDateFormatter.string(from: date)
        }
        picker.show(vc: self, sender: nil, mode: .date, minimum: nil, maximum: Date(), currentDate: nil)

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
            viewModel.registerRequestModel.country = country.countryCode
            viewModel.registerRequestModel.phone_code = country.phoneCode
        }
        let sheetVC = SheetViewController(controller: vc, sizes: [.fixed(UIScreen.main.bounds.height * 0.8)])
        sheetVC.handleColor = .clear
        sheetVC.dismissOnBackgroundTap = true
        sheetVC.topCornersRadius = 20
        self.present(sheetVC, animated: true)

    }

    @IBAction func specialityTapped(_ sender: UIButton) {
        let picker = PickerPopup.instance()
        picker.pickerTitle = "التخصص"
        picker.didPickValue = { [weak self] index in
            guard let self = self else { return }
            specialityTF.text = specialities[index].name
            viewModel.registerRequestModel.speciality_id = specialities[index].id ?? 100
        }
        let specialitiesStr = specialities.map { $0.name ?? "" }
        picker.show(vc: self, sender: nil, array: specialitiesStr, index: 0)
    }
    
    @IBAction func securePasswordTapped(_ sender: UIButton) {
        togglePasswordVisibility()
    }
    
    @IBAction func registerTapped(_ sender: UIButton) {
        viewModel.registerRequestModel.name = fullNameTF.text ?? ""
        viewModel.registerRequestModel.phone = phoneTF.text ?? ""
        viewModel.registerRequestModel.email = emailTF.text ?? ""
        viewModel.registerRequestModel.password = passwordTF.text ?? ""
        viewModel.register()
    }
    
    @IBAction func needHelpTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func startJourney(_ sender: UIButton) {
        AppCoordinator.shared.back()

    }
    

    
}

extension RegisterVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            if textField == self.phoneTF {
                self.phoneView.backgroundColor = .white
                self.phoneView.layer.borderColor = UIColor.Blue_Brand_500.cgColor
            } else if textField == self.fullNameTF {
                self.fullNameView.backgroundColor = .white
                self.fullNameView.layer.borderColor = UIColor.Blue_Brand_500.cgColor
            } else if textField == self.emailTF {
                self.emailView.backgroundColor = .white
                self.emailView.layer.borderColor = UIColor.Blue_Brand_500.cgColor
            } else {
                self.passwordView.backgroundColor = .white
                self.passwordView.layer.borderColor = UIColor.Blue_Brand_500.cgColor
            }
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            if textField == self.phoneTF {
                self.phoneView.backgroundColor = .Gray_50
                self.phoneView.layer.borderColor = UIColor.gray100.cgColor
            } else if textField == self.fullNameTF {
                self.fullNameView.backgroundColor = .Gray_50
                self.fullNameView.layer.borderColor = UIColor.gray100.cgColor
            } else if textField == self.emailTF {
                self.emailView.backgroundColor = .Gray_50
                self.emailView.layer.borderColor = UIColor.gray100.cgColor
            } else {
                self.passwordView.backgroundColor = .Gray_50
                self.passwordView.layer.borderColor = UIColor.gray100.cgColor
            }
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == phoneTF else { return true }
        
        let currentText = textField.text ?? ""
        let nsText = currentText as NSString
        let newText = nsText.replacingCharacters(in: range, with: string)
        
        // Prevent deletion of the leading "0"
        if range.location == 0 && range.length > 0 {
            return false
        }
        
        // Enforce that text always starts with "0"
        if !newText.hasPrefix("0") {
            textField.text = "0" + newText.filter { $0.isNumber && $0 != "0" }
            return false
        }
        
        return true
    }
    
}
