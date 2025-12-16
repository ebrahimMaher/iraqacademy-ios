//
//  VisionKitManager.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import Foundation
import UIKit
import Vision
import VisionKit


protocol VisionKitDelegate: AnyObject {
    func didFailWithError(_ error: VisionKitManager.VisionKitScanError)
    func didExtractNationalID(_ id: String, _ image: UIImage)
}

class VisionKitManager: NSObject {
    
    enum VisionKitScanError {
        case documentScanError, visionKitIsNotSupported, textRecognitionError, invalidNationalID(image: UIImage)
        
        var description: String {
            switch self {
            case .documentScanError: return "فشل في مسح المستند. الرجاء المحاولة مرة أخرى."
            case .visionKitIsNotSupported: return "هذا الجهاز لا يدعم ميزة مسح المستندات بالكاميرا."
            case .textRecognitionError: return "فشل في التعرف على النص من الصورة. تأكد من وضوح الصورة وحاول مرة أخرى."
            case .invalidNationalID: return "لم يتم العثور على بطاقة هوية وطنية صالحة. الرجاء التأكد من أن الصورة تحتوي على رقم هوية وصورة شخصية."
            }
        }
    }
    
    typealias VisionPresentingViewController = UIViewController & VisionKitDelegate
    weak var delegate: VisionKitDelegate?
    
    func presentDocumentScanner(from viewController: VisionPresentingViewController) {
        delegate = viewController
        guard VNDocumentCameraViewController.isSupported else {
            DispatchQueue.main.async { self.delegate?.didFailWithError(.visionKitIsNotSupported) }
            return
        }
        let scannerVC = VNDocumentCameraViewController()
        scannerVC.delegate = self
        viewController.present(scannerVC, animated: true)
    }
    
    
}

extension VisionKitManager: VNDocumentCameraViewControllerDelegate {
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true)
        for pageIndex in 0..<scan.pageCount {
            let image = scan.imageOfPage(at: pageIndex)
            recognizeTextInImage(image)
        }
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: any Error) {
        controller.dismiss(animated: true)
        DispatchQueue.main.async { self.delegate?.didFailWithError(.documentScanError) }
        print("Document scanning failed: \(error.localizedDescription)")
    }
    
}

extension VisionKitManager {
    
    private func convertToGrayscale(_ image: UIImage) -> UIImage? {
        let context = CIContext()
        guard let ciImage = CIImage(image: image) else { return nil }

        let grayscale = ciImage.applyingFilter("CIPhotoEffectMono")
        if let cgImage = context.createCGImage(grayscale, from: grayscale.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    
    private func increaseContrast(_ image: UIImage, amount: Float = 1.2) -> UIImage? {
        let context = CIContext()
        guard let ciImage = CIImage(image: image) else { return nil }

        let parameters: [String: Any] = [
            kCIInputImageKey: ciImage,
            "inputContrast": amount
        ]

        let contrasted = CIFilter(name: "CIColorControls", parameters: parameters)?.outputImage
        if let output = contrasted, let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage)
        }

        return nil
    }
    
    private func preprocess(_ image: UIImage) -> UIImage? {
        guard let gray = convertToGrayscale(image),
              let contrasted = increaseContrast(gray) else {
            return image
        }
        return contrasted
    }
    
    private func recognizeTextInImage(_ image: UIImage) {
        guard let preprocessed = preprocess(image),
              let cgImage = preprocessed.cgImage else { return }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let self else { return }
            guard error == nil else {
                DispatchQueue.main.async { self.delegate?.didFailWithError(.textRecognitionError) }
                print("Text recognition failed: \(error!.localizedDescription)")
                return
            }
            
            if let observations = request.results as? [VNRecognizedTextObservation] {
                let allText = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: " ")
                print("Extracted Text: \(allText)")
                self.extractNationalID(from: allText, and: image)
            }
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["ar", "en"]
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("Failed to perform text recognition: \(error.localizedDescription)")
            }
        }
    }
    
    
    // extract 12-digit numbers only
    private func extractNationalID(from text: String, and image: UIImage) {
        let pattern = "\\b\\d{12}\\b"
        let matches = matches(for: pattern, in: text)
        if let id = matches.first, isLikelyNationalID(text: text) {
            DispatchQueue.main.async { self.delegate?.didExtractNationalID(id, image) }
            print("✅ National ID is Found: \(id)")
        } else {
            
            DispatchQueue.main.async { self.delegate?.didFailWithError(.invalidNationalID(image: image)) }
            print("❌ No National ID is found.")
        }
    }

    
    private func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch {
            print("Regex error: \(error)")
            return []
        }
    }
        
    private func isLikelyNationalID(text: String) -> Bool {
        let keywords = [
            "الاسم",
            "اللقب",
            "الجنس",
            "الأب",
            "الجد",
            "الأم",
            "فصيلة",
            "الدم",
            "البطاقة",
            "الوطنية",
            "جمهورية",
            "العراق",
            "وزارة",
            "الداخلية",
            "مديرية",
            "الأحوال",
            "المدنية",
            "والجوازات",
            "والاقامة"
        ]
        let similarityScore = overallSimilarityScore(extractedText: text, keywords: keywords)
        print("\nkeywords similarity score = \(similarityScore)")
        return similarityScore > 0.7
    }
    
    private func characterSimilarity(_ a: String, _ b: String) -> Double {
        let aChars = Array(a)
        let bChars = Array(b)
        
        let minLength = min(aChars.count, bChars.count)
        var matches = 0
        
        for i in 0..<minLength {
            if aChars[i] == bChars[i] {
                matches += 1
            }
        }
        
        return Double(matches) / Double(max(aChars.count, bChars.count))
    }
    
    private func overallSimilarityScore(extractedText: String, keywords: [String]) -> Double {
        let normalizedText = extractedText.replacingOccurrences(of: "\n", with: " ")
        let textWords = normalizedText.components(separatedBy: " ").filter { !$0.isEmpty }

        var totalScore: Double = 0

        for keyword in keywords {
            var bestScore: Double = 0

            for word in textWords {
                let score = characterSimilarity(keyword, word)
                if score > bestScore {
                    bestScore = score
                }
            }

            totalScore += bestScore
        }

        let overallScore = totalScore / Double(keywords.count)
        return overallScore
    }
    

}
