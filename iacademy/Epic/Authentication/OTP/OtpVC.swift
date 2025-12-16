//
//  OtpVC.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import UIKit

class OtpVC: UIViewController {
        
    @IBOutlet var textFields: [OTPTextField]!
    @IBOutlet var textFieldsContainer: [UIView]!
    
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var resendTimerLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    private var resendTimer: Timer?
    private var resendCounter: Int = 30
    
    private let viewModel = OtpViewModel()
    private let loadingView = LoadingView()

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
        
        viewModel.didReceiveSuccess = { [weak self] in
            guard let self = self else { return }
            // navigate to New Password View Controller
        }
    }
    
    private func setupUI() {
        
        loadingView.setup(in: view)
        
        for (index, textfield) in textFields.enumerated() {
            textfield.delegate = self
            textfield.tag = index
            textfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            
            textfield.onDeleteBackward = { [weak self] in
                guard let self = self else { return }
                if textfield.text?.isEmpty ?? true {
                    let previousTag = textfield.tag - 1
                    if previousTag >= 0 {
                        self.textFields[previousTag].becomeFirstResponder()
                    }
                }
            }
        }
        
        for (index, container) in textFieldsContainer.enumerated() {
            container.layer.cornerRadius = 12
            container.layer.borderWidth = 1
            container.layer.borderColor = UIColor.Gray_100.cgColor
            container.backgroundColor = .Gray_50
            container.tag = index
        }
        
        checkConfirmButtonState()
        textFields.first?.becomeFirstResponder()
        resendButton.semanticContentAttribute = .forceRightToLeft
        resendButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: -3)
        resendButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -3, bottom: 0, right: 3)

        
    }
    
    private func checkConfirmButtonState() {
        var isEnabled = true
        for textfield in textFields {
            if (textfield.text ?? "").isEmpty {
                isEnabled = false
            }
        }
        confirmButton.backgroundColor = isEnabled ? .Blue_Brand_500 : .Gray_100
        confirmButton.setTitleColor(isEnabled ? .white : .Gray_300, for: .normal)
        confirmButton.isUserInteractionEnabled = isEnabled
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
        if text.count > 1 {
            textField.text = String(text.prefix(1))
        }
        
        if !text.isEmpty {
            let nextTag = textField.tag + 1
            if nextTag < textFields.count {
                textFields[nextTag].becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
        }
        
        checkConfirmButtonState()
    }
    
    
    @IBAction func textFieldsTapped(_ sender: UIButton) {
        if let emptyFieldIndex = textFields.firstIndex(where: { ($0.text ?? "").isEmpty }) {
            textFields[emptyFieldIndex].becomeFirstResponder()
        } else {
            textFields.last?.becomeFirstResponder()
        }
    }
    
    
    @IBAction func resendButtonTapped(_ sender: UIButton) {
        resendButton.backgroundColor = .Gray_100
        resendButton.setTitleColor(.Gray_300, for: .normal)
        resendButton.isUserInteractionEnabled = false
        resendCounter = 30
        resendTimer?.invalidate()
        resendTimer = nil
        resendTimerLabel.text = "يمكنك إعادة إرسال رمز التحقق خلال \(resendCounter) ثانية"
        resendTimerLabel.isHidden = false
        resendTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            if resendCounter < 1 {
                resendTimer?.invalidate()
                resendTimer = nil
                resendButton.backgroundColor = .Blue_Brand_500
                resendButton.setTitleColor(.white, for: .normal)
                resendButton.isUserInteractionEnabled = true
                resendTimerLabel.isHidden = true
            } else {
                resendCounter -= 1
                resendTimerLabel.text = "يمكنك إعادة إرسال رمز التحقق خلال \(resendCounter) ثانية"
            }
        })
    }
    
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        
    }
    
    
}

extension OtpVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let fieldIndex = textFields.firstIndex(where: { $0.tag == textField.tag }) {
            selectTextFieldContainer(true, container: textFieldsContainer[fieldIndex])
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let fieldIndex = textFields.firstIndex(where: { $0.tag == textField.tag }) {
            selectTextFieldContainer(false, container: textFieldsContainer[fieldIndex])
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacterSet = CharacterSet(charactersIn: "0123456789")
        return string.rangeOfCharacter(from: allowedCharacterSet.inverted) == nil
    }
    
    
    
    
    private func selectTextFieldContainer(_ isSelected: Bool, container: UIView) {
        UIView.animate(withDuration: 0.3) {
            container.layer.borderColor = isSelected ? UIColor.Blue_Brand_500.cgColor : UIColor.Gray_100.cgColor
            container.backgroundColor = isSelected ? .white : .Gray_50
        }
    }
    
}
