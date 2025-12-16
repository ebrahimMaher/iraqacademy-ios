//
//  IDVerificationVC.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import UIKit

class IDVerificationVC: UIViewController {
    
    enum SelectedImage {
        case frontNationalID, backNationalID, residence
    }
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var subHeaderLabel: UILabel!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var frontView: UIView!
    @IBOutlet weak var frontLabel: UILabel!
    @IBOutlet weak var frontCameraImage: UIImageView!
    @IBOutlet weak var frontDeleteButton: UIButton!
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var backCameraImage: UIImageView!
    @IBOutlet weak var backLabel: UILabel!
    @IBOutlet weak var backDeleteButton: UIButton!
    
    @IBOutlet weak var resView: UIView!
    @IBOutlet weak var resLabel: UILabel!
    @IBOutlet weak var resCameraImage: UIImageView!
    @IBOutlet weak var resDeleteButton: UIButton!
    
    @IBOutlet weak var verifyButton: UIButton!
    
    
    private var visionKitManager: VisionKitManager?
    private var imagePicker: ImagePickerManager?
    
    private var selectedImage: SelectedImage?
    
    private let viewModel = IDVerificationViewModel()
    private let loadingView = LoadingView()

    override func viewDidLoad() {
        super.viewDidLoad()
     
        bind()
        setupUI()
        viewModel.fetchVerificationStatus()
    }
    
    private func setupUI() {
        loadingView.setup(in: view)
        contentView.isHidden = true
        setFrontViewSelected(false)
        setBackViewSelected(false)
        setResViewSelected(false)
        updateVerifyButtonState(isEnabled: false)
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
        
        viewModel.didReceiveVerificationSuccess = { [weak self] in
            guard let self = self else { return }
            NotificationCenter.default.post(name: Notification.Name("National ID Verified"), object: nil)
            showSimpleAlert(title: "تم بنجاح", message: "تم إرسال طلبك بنجاح")
            viewModel.frontImage = nil ; viewModel.backImage = nil ; viewModel.resImage = nil ; viewModel.nationalID = nil
            setFrontViewSelected(false) ; setBackViewSelected(false) ; setResViewSelected(false)
            updateVerifyButtonState(isEnabled: false)
            viewModel.fetchVerificationStatus()
        }

        viewModel.didReceiveStatus = { [weak self] status in
            guard let self = self else { return }
            contentView.isHidden = false
            if status.isVerified {
                contentView.isUserInteractionEnabled = false
                headerImageView.image = .init(systemName: "checkmark.circle.fill")
                headerImageView.tintColor = .Green_600
                headerLabel.textColor = .Green_600
                headerLabel.text = "تم توثيق حسابك بنجاح"
                subHeaderLabel.text = ""
            } else if status.isInReview {
                contentView.isUserInteractionEnabled = false
                headerImageView.image = .init(named: "profile_edit")
                headerImageView.tintColor = .clear
                headerLabel.text = "طلبك قيد المراجعة"
                headerLabel.textColor = .black
                subHeaderLabel.text = ""
            } else if status.isNotVerified {
                contentView.isUserInteractionEnabled = true
                headerImageView.image = .init(named: "profile_edit")
                headerImageView.tintColor = .clear
                headerLabel.text = "يجب توثيق حسابك للمتابعة"
                headerLabel.textColor = .black
                subHeaderLabel.text = ""
            } else if status.rejected {
                contentView.isUserInteractionEnabled = true
                headerImageView.image = .init(systemName: "xmark.circle.fill")
                headerImageView.tintColor = .Red_600
                headerLabel.textColor = .Red_600
                subHeaderLabel.textColor = .Red_600
                headerLabel.text = "خطأ في التوثيق"
                subHeaderLabel.text = status.rejectionReason ?? ""
            }
        }

    }

    
    func presentDocumentScanner() {
        visionKitManager = VisionKitManager()
        visionKitManager?.presentDocumentScanner(from: self)
    }
    
    func presentImagePicker() {
        imagePicker = ImagePickerManager()
        imagePicker?.presentCameraImagePicker(from: self)
    }

    @IBAction func addFrontImageTapped(_ sender: UIButton) {
        selectedImage = .frontNationalID
        presentDocumentScanner()
    }
    
    @IBAction func deleteFrontImageTapped(_ sender: UIButton) {
        viewModel.frontImage = nil
        viewModel.nationalID = nil
        setFrontViewSelected(false)
    }
    
    @IBAction func addBackImageTapped(_ sender: UIButton) {
        selectedImage = .backNationalID
        presentImagePicker()
    }
    
    @IBAction func deleteBackImageTapped(_ sender: UIButton) {
        viewModel.backImage = nil
        setBackViewSelected(false)
    }
    
    @IBAction func addResImageTapped(_ sender: UIButton) {
        selectedImage = .residence
        presentImagePicker()
    }
    
    @IBAction func deleteResImageTapped(_ sender: UIButton) {
        viewModel.resImage = nil
        setResViewSelected(false)
    }
    
    @IBAction func verifyTapped(_ sender: UIButton) {
        viewModel.verifyID()
    }
    
    
}


extension IDVerificationVC: VisionKitDelegate {
    
    func didFailWithError(_ error: VisionKitManager.VisionKitScanError) {
        if case .invalidNationalID(let image) = error {
            showAlertWithCancel(title: "خطأ",
                                message: "فشل التحقق الآلي من بطاقة الهوية، سيتم إرسال الهوية للتحقق اليدوي، ربما تستغرق عملية التحقق بعض الوقت.",
                                okActionName: "تأكيد") {
                self.viewModel.frontImage = image
                self.viewModel.nationalID = nil
                self.setFrontViewSelected(true)
            }
        } else {
            viewModel.frontImage = nil
            viewModel.nationalID = nil
            showSimpleAlert(title: "خطأ", message: error.description)
            setFrontViewSelected(false)
        }
        updateVerifyButtonState(isEnabled: viewModel.verifyButtonEnabled)
    }
    
    func didExtractNationalID(_ id: String, _ image: UIImage) {
        viewModel.frontImage = image
        viewModel.nationalID = id
        setFrontViewSelected(true)
        updateVerifyButtonState(isEnabled: viewModel.verifyButtonEnabled)
    }
        
    
}

extension IDVerificationVC: ImagePickerDelegate {
    
    func didFailWithError(_ error: ImagePickerManager.ImagePickerError) {
        showSimpleAlert(title: "خطأ", message: error.description)
        if error == .photoLibraryPermissionNotAuthorized || error == .cameraPermissionNotAuthorized {
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(appSettings) {
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    func didSelectImage(_ image: UIImage) {
        if selectedImage == .backNationalID {
            viewModel.backImage = image
            setBackViewSelected(true)
            updateVerifyButtonState(isEnabled: viewModel.verifyButtonEnabled)
        }
        else if selectedImage == .residence {
            viewModel.resImage = image
            setResViewSelected(true)
            updateVerifyButtonState(isEnabled: viewModel.verifyButtonEnabled)
        }
    }
    
    
}

extension IDVerificationVC {
    
    private func updateVerifyButtonState(isEnabled: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.verifyButton.backgroundColor = isEnabled ? .Blue_Brand_500 : .Gray_100
            self.verifyButton.setTitleColor(isEnabled ? .white : .Gray_300, for: .normal)
            self.verifyButton.isUserInteractionEnabled = isEnabled
        }
    }
    
    private func setFrontViewSelected(_ isSelected: Bool) {
        frontDeleteButton.isHidden = !isSelected
        frontView.backgroundColor = isSelected ? .white : .Gray_100
        frontView.layer.borderColor = isSelected ? UIColor.Blue_Brand_500.cgColor : UIColor.clear.cgColor
        frontLabel.textColor = isSelected ? .black : .Gray_400
        frontCameraImage.isHidden = isSelected
    }
    
    private func setBackViewSelected(_ isSelected: Bool) {
        backDeleteButton.isHidden = !isSelected
        backView.backgroundColor = isSelected ? .white : .Gray_100
        backView.layer.borderColor = isSelected ? UIColor.Blue_Brand_500.cgColor : UIColor.clear.cgColor
        backLabel.textColor = isSelected ? .black : .Gray_400
        backCameraImage.isHidden = isSelected
    }
    
    private func setResViewSelected(_ isSelected: Bool) {
        resDeleteButton.isHidden = !isSelected
        resView.backgroundColor = isSelected ? .white : .Gray_100
        resView.layer.borderColor = isSelected ? UIColor.Blue_Brand_500.cgColor : UIColor.clear.cgColor
        resLabel.textColor = isSelected ? .black : .Gray_400
        resCameraImage.isHidden = isSelected
    }
}
