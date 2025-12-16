//
//  EditProfileVC.swift
//  iacademy
//
//  Created by Marwan Osama on 15/12/2025.
//

import UIKit
import Photos

class EditProfileVC: UIViewController {
    
    @IBOutlet weak var navigationHeader: NavigationHeader!
    @IBOutlet weak var successBannerView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var editAvatarButton: UIButton!
    
    @IBOutlet weak var fullNameTF: UITextField!
    @IBOutlet weak var fullNameView: UIView!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var saveProfileButton: UIButton!
    
    @IBOutlet weak var changePasswordView: UIView!
    
    private let viewModel = EditProfileViewModel()
    private let loadingView = LoadingView()
    
    var onProfileUpdated: (() -> Void)?

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
        
        viewModel.didUploadImageSuccess = { [weak self] profileResponse in
            guard let self = self else { return }
            handleProfileResponse(profileResponse)
        }
        
        viewModel.didUpdateProfileSuccess = { [weak self] profileResponse in
            guard let self = self else { return }
            handleProfileResponse(profileResponse)
        }
    }
    
    private func setupUI() {
        navigationHeader.title = "إدارة الحساب"
        configureLoading()
        setupViewFields()
        setupAvatarAndSaveButton()
        addTapGesture(to: changePasswordView, action: #selector(passwordTapped))
        
        if let user = CacheClient.shared.userModel {
            populateUserData(user)
        }
    }
    
    private func configureLoading() {
        loadingView.setup(in: view)
        contentView.isHidden = true
        successBannerView.isHidden = true
    }
    
    private func setupViewFields() {
        [fullNameTF, emailTF].forEach {
            $0?.delegate = self
            $0?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
        fullNameTF.attributedPlaceholder = NSAttributedString(
            string: "أدخل الإسم بالكامل",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.Gray_400]
        )
        emailTF.attributedPlaceholder = NSAttributedString(
            string: "أدخل بريدك الإلكتروني",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.Gray_400]
        )
    }
    
    private func setupAvatarAndSaveButton() {
        updateSaveButtonState(isEnabled: false)
        saveProfileButton.addTarget(self, action: #selector(saveProfileTapped(_:)), for: .touchUpInside)
        saveProfileButton.titleLabel?.font = UIFont.rubikFont(weight: .medium, size: 16)
        
        editAvatarButton.addTarget(self, action: #selector(editAvatarTapped(_:)), for: .touchUpInside)
    }
    
    private func updateSaveButtonState(isEnabled: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.saveProfileButton.backgroundColor = isEnabled ? .Blue_Brand_500 : .Gray_100
            self.saveProfileButton.setTitleColor(isEnabled ? .white : .Gray_300, for: .normal)
            self.saveProfileButton.isUserInteractionEnabled = isEnabled
        }
    }
    
    private func addTapGesture(to view: UIView, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: self, action: action)
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tapGesture)
    }
    
    private func handleProfileResponse(_ profileResponse: ProfileResponseModel) {
        guard let user = profileResponse.user else { return }
        showSuccessBanner(withDuration: 2.0)
        CacheClient.shared.userModel = user
        populateUserData(user)
        onProfileUpdated?()
    }
    
    private func populateUserData(_ user: UserModelResponse) {
        contentView.isHidden = false
        fullNameTF.text = user.name ?? ""
        emailTF.text = user.email ?? ""
        avatarImageView.kf.setImage(with: URL(string: user.avatar ?? ""), placeholder: UIImage(named: "profile_placeholder"), options: [.transition(.fade(0.3)), .cacheMemoryOnly])
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
    
    @objc private func editAvatarTapped(_ sender: UIButton) {
        requestImageAuthorization()
    }
    
    @objc private func saveProfileTapped(_ sender: UIButton) {
        view.endEditing(true)
        viewModel.saveProfile()
    }
    
    @objc private func passwordTapped() {
        AppCoordinator.shared.navigate(to: .changePassword)
    }
}

extension EditProfileVC: UITextFieldDelegate {
    @objc private func textFieldDidChange(_ textField: UITextField) {
        viewModel.setInputs(name: fullNameTF.text ?? "",
                            email: emailTF.text ?? "")
        updateSaveButtonState(isEnabled: viewModel.isFormValid)
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
            case self.fullNameTF:
                self.fullNameView.backgroundColor = background
                self.fullNameView.layer.borderColor = color
            case self.emailTF:
                self.emailView.backgroundColor = background
                self.emailView.layer.borderColor = color
            default:
                break
            }
        }
    }
}

extension EditProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func requestImageAuthorization() {
        requestPhotoPermissionIfNeeded { granted in
            if granted {
                self.presentImagePicker()
            } else {
                self.showSimpleAlert(title: "خطأ", message: "يرجى السماح بالوصول إلى الصورة من الإعدادات لاختيار صورة ملفك الشخصي.")
            }
        }
    }
    
    func requestPhotoPermissionIfNeeded(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
        default:
            completion(false)
        }
    }
    
    private func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true)
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        
        guard let imageData = selectedImage.jpegData(compressionQuality: 0.8) ?? selectedImage.pngData() else {
            return
        }
        
        let isPNG = selectedImage.jpegData(compressionQuality: 0.8) == nil
        let mimeType = isPNG ? "image/png" : "image/jpeg"
        let fileName = isPNG ? "avatar.png" : "avatar.jpg"
        viewModel.uploadAvatarImage(imageData, mimeType, fileName)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
