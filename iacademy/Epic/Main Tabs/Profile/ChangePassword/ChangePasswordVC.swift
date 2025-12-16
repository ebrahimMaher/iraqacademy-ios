//
//  ChangePasswordVC.swift
//  iacademy
//
//  Created by Marwan Osama on 15/12/2025.
//

import UIKit

class ChangePasswordVC: UIViewController {
    
    @IBOutlet weak var navigationHeader: NavigationHeader!
    @IBOutlet weak var successBannerView: UIView!
    
    @IBOutlet weak var oldPasswordTF: UITextField!
    @IBOutlet weak var oldPasswordView: UIView!
    @IBOutlet weak var oldPasswordSecureButton: UIButton!
    
    @IBOutlet weak var newPasswordTF: UITextField!
    @IBOutlet weak var newPasswordView: UIView!
    @IBOutlet weak var newPasswordSecureButton: UIButton!
    
    @IBOutlet weak var confirmPasswordTF: UITextField!
    @IBOutlet weak var confirmPasswordView: UIView!
    @IBOutlet weak var confirmPasswordSecureButton: UIButton!
    
    @IBOutlet weak var changePasswordButton: UIButton!
    
    private let viewModel = ChangePasswordViewModel()
    private let loadingView = LoadingView()

    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        setupUI()
    }
    
    private func bind() {
        viewModel.didReceiveError = { [weak self] error in
            guard let self = self else { return }
            showSimpleAlert(title: "خطأ", message: error)
        }
        
        viewModel.didReceiveValidationError = { [weak self] error, isMoreThanOneError in
            guard let self = self else { return }
            isMoreThanOneError ? showRightAlignedAlert(title: "خطأ في التحقق", message: error) : showSimpleAlert(title: "خطأ في التحقق", message: error)
        }
        
        viewModel.didReceiveLoading = { [weak self] loading in
            guard let self = self else { return }
            loadingView.isHidden = !loading
        }
        
        viewModel.didReceiveSuccess = { [weak self] in
            guard let self = self else { return }
            handleUpdateResponse()
        }
    }
    
    private func setupUI() {
        navigationHeader.title = "تغيير كلمة المرور"
        configureLoading()
        setupSecureButtons()
        setupViewFields()
        setupChangePasswordButton()
    }
    
    private func configureLoading() {
        loadingView.setup(in: view)
        successBannerView.isHidden = true
    }
    
    private func setupViewFields() {
        [oldPasswordTF, newPasswordTF, confirmPasswordTF].forEach {
            $0?.delegate = self
            $0?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            $0?.attributedPlaceholder = NSAttributedString(
                string: "أدخل كلمة المرور",
                attributes: [.foregroundColor: UIColor.Gray_400]
            )
        }
    }
    
    private func setupSecureButtons() {
        [oldPasswordSecureButton, newPasswordSecureButton, confirmPasswordSecureButton].forEach {
            $0?.addTarget(self, action: #selector(securePasswordTapped(_:)), for: .touchUpInside)
        }
    }
    
    private func setupChangePasswordButton() {
        updateChangeButtonState(isEnabled: false)
        changePasswordButton.addTarget(self, action: #selector(changePasswordTapped(_:)), for: .touchUpInside)
        changePasswordButton.titleLabel?.font = UIFont.rubikFont(weight: .medium, size: 16)
    }
    
    private func updateChangeButtonState(isEnabled: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.changePasswordButton.backgroundColor = isEnabled ? .Blue_Brand_500 : .Gray_100
            self.changePasswordButton.setTitleColor(isEnabled ? .white : .Gray_300, for: .normal)
            self.changePasswordButton.isUserInteractionEnabled = isEnabled
        }
    }
    
    private func togglePasswordVisibility(_ field: UITextField, _ button: UIButton) {
        field.isSecureTextEntry.toggle()
        button.tintColor = field.isSecureTextEntry ? .Gray_400 : .Gray_900
    }
    
    private func handleUpdateResponse() {
        showSuccessBanner(withDuration: 2.0)
        resetViewState()
    }
    
    private func resetViewState() {
        updateChangeButtonState(isEnabled: false)
        [oldPasswordTF, newPasswordTF, confirmPasswordTF].forEach {
            $0?.text = ""
        }
    }
    
    private func showSuccessBanner(withDuration: TimeInterval = 2.0) {
        successBannerView.isHidden = false
        successBannerView.alpha = 0

        UIView.animate(withDuration: 0.3) {[weak self] in
            guard let self = self else { return }
            successBannerView.alpha = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + withDuration) {[weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.3, animations: {
                self.successBannerView.alpha = 0
            }) { _ in
                self.successBannerView.isHidden = true
            }
        }
    }
    
    @objc private func securePasswordTapped(_ sender: UIButton) {
        switch sender.tag {
        case 1: togglePasswordVisibility(oldPasswordTF, oldPasswordSecureButton)
        case 2: togglePasswordVisibility(newPasswordTF, newPasswordSecureButton)
        case 3: togglePasswordVisibility(confirmPasswordTF, confirmPasswordSecureButton)
            
        default:
            return
        }
    }
    
    @objc private func changePasswordTapped(_ sender: UIButton) {
        view.endEditing(true)
        viewModel.changePassword()
    }
    
    @IBAction func forgetPasswordTapped(_ sender: UIButton) {
        AppCoordinator.shared.navigate(to: .resetPassword)
    }
    
    
}

extension ChangePasswordVC: UITextFieldDelegate {
    @objc private func textFieldDidChange(_ textField: UITextField) {
        viewModel.setPasswordInputs(old: oldPasswordTF.text ?? "",
                                    new: newPasswordTF.text ?? "",
                                    confirm: confirmPasswordTF.text ?? "")
        updateChangeButtonState(isEnabled: viewModel.isFormValid)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        highlightView(for: textField, isEditing: true)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        highlightView(for: textField, isEditing: false)
    }

    private func highlightView(for textField: UITextField, isEditing: Bool) {
        let color = isEditing ? UIColor.Blue_Brand_500.cgColor : UIColor.gray100.cgColor
        let background = isEditing ? UIColor.white : UIColor.Gray_50
        UIView.animate(withDuration: 0.3) {
            switch textField {
            case self.oldPasswordTF:
                self.oldPasswordView.backgroundColor = background
                self.oldPasswordView.layer.borderColor = color
            case self.newPasswordTF:
                self.newPasswordView.backgroundColor = background
                self.newPasswordView.layer.borderColor = color
            case self.confirmPasswordTF:
                self.confirmPasswordView.backgroundColor = background
                self.confirmPasswordView.layer.borderColor = color
            default:
                break
            }
        }
    }
}

