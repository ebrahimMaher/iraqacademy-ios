//
//  ForgetPasswordVC.swift
//  iacademy
//
//  Created by Marwan Osama on 13/02/2026.
//

import UIKit
import SafariServices

class ForgetPasswordVC: UIViewController {

    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var phoneTF: AppTextField!
    
    var safariVC: SFSafariViewController?
    
    private let loadingView = LoadingView()
    private let viewModel = ForgetPasswordViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bind()

    }
    
    private func setupUI() {
        loadingView.setup(in: self.view)
        phoneTF.delegate = self
        phoneTF.text = "0"
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
        
        viewModel.didReceiveVerificationLink = { [weak self] link in
            guard let self = self else { return }
            beginTelegramVerification(link: link)
        }
    }

    private func beginTelegramVerification(link: String) {
        if let url = URL(string: link) {
            let safariVC = SFSafariViewController(url: url)
            safariVC.delegate = self
            self.safariVC = safariVC
            present(safariVC, animated: true)
        }
    }
    
    @IBAction func verifyTapped(_ sender: UIButton) {
        viewModel.forgetPasswordVerify(phone: phoneTF.text ?? "")
    }
    
    @IBAction func backToLoginTapped(_ sender: UIButton) {
        AppCoordinator.shared.back()
    }
    
}

extension ForgetPasswordVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
            self.phoneView.layer.borderColor = UIColor.Blue_Brand_500.cgColor
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.3) {
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

extension ForgetPasswordVC: SFSafariViewControllerDelegate {
    
    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        print("Safari activityItemsFor \(URL.absoluteString) - title \(title)")
        return []
    }
    
    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        print("Safari initialLoadDidRedirectTo \(URL.absoluteString)")
    }
}

