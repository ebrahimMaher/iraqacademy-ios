//
//  SetNewPasswordVC.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import UIKit

class SetNewPasswordVC: UIViewController {
    
    @IBOutlet weak var newPasswordTF: UITextField!
    @IBOutlet weak var newPasswordView: UIView!
    @IBOutlet weak var newPasswordSecureButton: UIButton!
    
    @IBOutlet weak var confirmPasswordTF: UITextField!
    @IBOutlet weak var confirmPasswordView: UIView!
    @IBOutlet weak var confirmPasswordSecureButton: UIButton!
    
    @IBOutlet weak var setNewPasswordButton: UIButton!

    private let viewModel = SetNewPasswordViewModel()
    private let loadingView = LoadingView()

    var token: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
        
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
        
        viewModel.didReceiveTokenExpired = { [weak self] in
            guard let self = self else { return }
            AppCoordinator.shared.back()
        }
    }
    
    private func setupUI() {
        loadingView.setup(in: view)
                
        [newPasswordTF, confirmPasswordTF].forEach {
            $0?.delegate = self
            $0?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            $0?.attributedPlaceholder = NSAttributedString(
                string: "أدخل كلمة المرور",
                attributes: [.foregroundColor: UIColor.Gray_400]
            )
        }
        updateChangeButtonState(isEnabled: false)
        setNewPasswordButton.titleLabel?.font = UIFont.rubikFont(weight: .medium, size: 16)
    }
    
    private func togglePasswordVisibility(_ field: UITextField, _ button: UIButton) {
        field.isSecureTextEntry.toggle()
        button.tintColor = field.isSecureTextEntry ? .Gray_400 : .Gray_900
    }
    
    private func updateChangeButtonState(isEnabled: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.setNewPasswordButton.backgroundColor = isEnabled ? .Blue_Brand_500 : .Gray_100
            self.setNewPasswordButton.setTitleColor(isEnabled ? .white : .Gray_300, for: .normal)
            self.setNewPasswordButton.isUserInteractionEnabled = isEnabled
        }
    }

    @IBAction func securePasswordTapped(_ sender: UIButton) {
        switch sender.tag {
        case 1: togglePasswordVisibility(newPasswordTF, newPasswordSecureButton)
        case 2: togglePasswordVisibility(confirmPasswordTF, confirmPasswordSecureButton)
        default:
            return
        }
    }
    
    @IBAction func setNewPasswordTapped(_ sender: UIButton) {
        view.endEditing(true)
        viewModel.setNewPassword(token: token)
    }

}

extension SetNewPasswordVC: UITextFieldDelegate {
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        viewModel.setPasswordInputs(new: newPasswordTF.text ?? "",
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
