//
//  ImagePickerManager.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import UIKit
import AVFoundation
import Photos

protocol ImagePickerDelegate: AnyObject {
    func didFailWithError(_ error: ImagePickerManager.ImagePickerError)
    func didSelectImage(_ image: UIImage)
}

class ImagePickerManager: NSObject {
    
    enum ImagePickerError {
        case cameraPermissionNotAuthorized
        case cameraSourceTypeNotAvailable
        case photoLibraryPermissionNotAuthorized
        case photoLibrarySourceTypeNotAvailable
        
        var description: String {
            switch self {
            case .cameraPermissionNotAuthorized: return "تم رفض إذن الوصول إلى الكاميرا. يرجى تفعيل الإذن من إعدادات الخصوصية."
            case .cameraSourceTypeNotAvailable: return "الكاميرا غير متوفرة على هذا الجهاز."
            case .photoLibraryPermissionNotAuthorized: return "تم رفض إذن الوصول إلى مكتبة الصور. يرجى تفعيل الإذن من إعدادات الخصوصية."
            case .photoLibrarySourceTypeNotAvailable: return "مكتبة الصور غير متوفرة على هذا الجهاز."
            }
        }
    }

    
    typealias ImagePickerPresentingController = UIViewController & ImagePickerDelegate
    weak var delegate: ImagePickerDelegate?
    
    
    func presentCameraImagePicker(from viewController: ImagePickerPresentingController) {
        delegate = viewController
        checkCameraPermission { [weak self] granted in
            guard let self else { return }
            if granted {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let picker = UIImagePickerController()
                    picker.sourceType = .camera
                    picker.delegate = self
                    viewController.present(picker, animated: true)
                } else {
                    DispatchQueue.main.async { self.delegate?.didFailWithError(.cameraSourceTypeNotAvailable) }
                }
            } else {
                DispatchQueue.main.async { self.delegate?.didFailWithError(.cameraPermissionNotAuthorized) }
            }
        }
    }
    
    func presentPhotoLibraryImagePicker(from viewController: ImagePickerPresentingController) {
        delegate = viewController
        checkPhotoLibraryPermission { [weak self] granted in
            guard let self else { return }
            if granted {
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    let picker = UIImagePickerController()
                    picker.sourceType = .photoLibrary
                    picker.delegate = self
                    viewController.present(picker, animated: true)
                } else {
                    DispatchQueue.main.async { self.delegate?.didFailWithError(.photoLibrarySourceTypeNotAvailable) }
                }
            } else {
                DispatchQueue.main.async { self.delegate?.didFailWithError(.photoLibraryPermissionNotAuthorized) }
            }
        }
    }
    
    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .restricted, .denied:
            completion(false)
        case .authorized:
            completion(true)
        default:
            completion(false)
        }

    }
    
    private func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
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
        case .denied, .restricted:
            completion(false)
        default:
            completion(false)
        }
    }

}

extension ImagePickerManager: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            DispatchQueue.main.async { self.delegate?.didSelectImage(image) }
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
}

