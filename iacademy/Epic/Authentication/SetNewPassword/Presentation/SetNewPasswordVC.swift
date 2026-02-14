//
//  SetNewPasswordVC.swift
//  iacademy
//
//  Created by Marwan Osama on 14/02/2026.
//

import UIKit

class SetNewPasswordVC: UIViewController {
    
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var passwordTF: AppTextField!
    @IBOutlet weak var passwordVisibilityButton: UIButton!
    
    @IBOutlet weak var confirmPasswordTF: AppTextField!
    @IBOutlet weak var confirmPasswordView: UIView!
    @IBOutlet weak var confirmPasswordVisibilityButton: UIButton!
    
    @IBOutlet weak var setNewPasswordButton: AppButton!
    
    private let loadingView = LoadingView()
    private let viewModel = SetNewPasswordViewModel()
    
    var token: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bind()
    }
    
    private func setupUI() {
        loadingView.setup(in: view)
                
        [passwordTF, confirmPasswordTF].forEach {
            $0?.delegate = self
            $0?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
        updateChangeButtonState(isEnabled: false)
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
            showSimpleAlert(title: "تم بنجاح", message: "تمت إعادة تعيين كلمة المرور بنجاح.") {
                CacheClient.shared.clearAll()
                AppCoordinator.shared.setRoot(to: .login)
            }
        }
        
        viewModel.didReceiveTokenExpired = { [weak self] error in
            guard let self = self else { return }
            showSimpleAlert(title: "خطأ", message: error) {
                AppCoordinator.shared.back()
            }
        }
    }
    
    private func toggleVisibility(_ field: UITextField, _ button: UIButton) {
        field.isSecureTextEntry.toggle()
        button.setImage(.init(systemName: field.isSecureTextEntry ? "eye" : "eye.slash"), for: .normal)
    }
    
    private func updateChangeButtonState(isEnabled: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.setNewPasswordButton.backgroundColor = isEnabled ? .Blue_Brand_500 : .Gray_100
            self.setNewPasswordButton.setTitleColor(isEnabled ? .white : .Gray_300, for: .normal)
            self.setNewPasswordButton.isUserInteractionEnabled = isEnabled
        }
    }

    @IBAction func togglePasswordVisibility(_ sender: Any) {
        toggleVisibility(passwordTF, passwordVisibilityButton)
    }
    
    
    @IBAction func toggleConfirmPasswordVisibility(_ sender: Any) {
        toggleVisibility(confirmPasswordTF, confirmPasswordVisibilityButton)
    }
    

    @IBAction func saveTapped(_ sender: UIButton) {
        viewModel.setNewPassword(token: token)
    }
    
}

extension SetNewPasswordVC: UITextFieldDelegate {
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        viewModel.setPasswordInputs(new: passwordTF.text ?? "",
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
            case self.passwordTF:
                self.passwordView.layer.borderColor = color
            case self.confirmPasswordTF:
                self.confirmPasswordView.layer.borderColor = color
            default:
                break
            }
        }
    }
}
