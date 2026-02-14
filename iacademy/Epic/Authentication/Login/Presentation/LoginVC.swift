//
//  LoginVC.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import UIKit

class LoginVC: UIViewController {
    
    
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var securePasswordButton: UIButton!
    @IBOutlet weak var forgetPasswordLabel: UILabel!
   
    private let loadingView = LoadingView()
    private let viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
        setupUI()
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
        
        viewModel.didReceiveLoginResponse = { [weak self] loginResponse in
            guard let self = self else { return }
            handleLoginResponse(loginResponse)
        }
        
        
        
    }
    
    private func handleLoginResponse(_ loginResponse: LoginResponseModel) {
        CacheClient.shared.authToken = loginResponse.token ?? ""
        CacheClient.shared.userModel = loginResponse.user
        CacheClient.shared.lastLoginPhone = viewModel.loginRequestModel.phone
        if loginResponse.user?.accountVerified ?? false {
            CacheClient.shared.isAccountVerified = true
            AppCoordinator.shared.setRoot(to: .main)
        } else {
            CacheClient.shared.isAccountVerified = false
            AppCoordinator.shared.navigate(to: .userVerification)
        }
    }
    
    private func setupUI() {
        
        loadingView.setup(in: self.view)
        
        phoneTF.delegate = self
        passwordTF.delegate = self
                
        phoneTF.text = CacheClient.shared.lastLoginPhone
        
        let text = forgetPasswordLabel.text ?? ""
        let attributedString = NSAttributedString(
            string: text,
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )
        forgetPasswordLabel.attributedText = attributedString
        
        checkLoggedInPreviousState()
    }
    
    private func checkLoggedInPreviousState() { // check if user logged in before and didn't verify yet
        let isLoggedIn = !CacheClient.shared.authToken.isEmpty
        let isVerified = CacheClient.shared.isAccountVerified
        let userModel = CacheClient.shared.userModel
        if isLoggedIn, !isVerified, let name = userModel?.name, let phone = userModel?.phone {
            showAlertWithCancel(title: "إكمال عملية التحقق", message: "لقد قمت بتسجيل الدخول مسبقًا بهذا الرقم \(phone) والاسم \(name)، هل ترغب في متابعة عملية التحقق؟", okActionName: "إكمال") {
                AppCoordinator.shared.navigate(to: .userVerification)
            }
        }
    }
    
    private func togglePasswordVisibility() {
        passwordTF.isSecureTextEntry.toggle()
        securePasswordButton.setImage(.init(systemName: passwordTF.isSecureTextEntry ? "eye" : "eye.slash"), for: .normal)
    }
    

    @IBAction func securePasswordTapped(_ sender: UIButton) {
        togglePasswordVisibility()
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        viewModel.loginRequestModel.phone = phoneTF.text ?? ""
        viewModel.loginRequestModel.password = passwordTF.text ?? ""
        viewModel.login()
    }
    
    @IBAction func registerTapped(_ sender: UIButton) {
        AppCoordinator.shared.navigate(to: .register)
    }
    
    @IBAction func needHelpTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func forgetPasswordTapped(_ sender: UIButton) {
        AppCoordinator.shared.navigate(to: .forgetPassword)
    }
    
    
    
}

extension LoginVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            if textField == self.phoneTF {
                self.phoneView.layer.borderColor = UIColor.Blue_Brand_500.cgColor
            } else {
                self.passwordView.layer.borderColor = UIColor.Blue_Brand_500.cgColor
            }
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            if textField == self.phoneTF {
                self.phoneView.layer.borderColor = UIColor.gray100.cgColor
            } else {
                self.passwordView.layer.borderColor = UIColor.gray100.cgColor
            }
        }
        
    }
    
}
