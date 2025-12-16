//
//  FairPlayDRMManager.swift
//  iacademy
//
//  Created by Marwan Osama on 14/12/2025.
//

import AVKit
import UIKit

class FairPlayDRMManager: NSObject, AVContentKeySessionDelegate {
    
    private let licenseURL: URL
    private let certificateURL: URL
    private var contentKeySession: AVContentKeySession?
    
    init(licenseURL: URL, certificateURL: URL) {
        self.licenseURL = licenseURL
        self.certificateURL = certificateURL
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        contentKeySession = AVContentKeySession(keySystem: .fairPlayStreaming)
        contentKeySession?.setDelegate(self, queue: DispatchQueue(label: "fps_queue"))
    }
    
    func addAsset(_ asset: AVURLAsset) {
        contentKeySession?.addContentKeyRecipient(asset)
    }
    
    func contentKeySession(_ session: AVContentKeySession,
                           didProvide keyRequest: AVContentKeyRequest) {
        
        URLSession.shared.dataTask(with: certificateURL) { certData, _, error in
            guard let certData = certData, error == nil else {
                print("❌ Failed to load certificate: \(error?.localizedDescription ?? "unknown error")")
                keyRequest.processContentKeyResponseError(
                    error ?? NSError(domain: "FairPlay", code: -1, userInfo: [NSLocalizedDescriptionKey: "Certificate load failed"])
                )
                return
            }
            
            Task {
                do {
                    guard let assetIDString = keyRequest.identifier as? String,
                          let assetIDData = assetIDString.data(using: .utf8) else {
                        throw NSError(domain: "FairPlay", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid Asset ID"])
                    }
                    let spcData = try await keyRequest.makeStreamingContentKeyRequestData(
                        forApp: certData,
                        contentIdentifier: assetIDData,
                        options: nil
                    )
                    self.sendSPCToKeyServer(spcData) { ckcData in
                        let response = AVContentKeyResponse(fairPlayStreamingKeyResponseData: ckcData)
                        keyRequest.processContentKeyResponse(response)
                    }
                    
                } catch {
                    print("⚠️ Failed to generate SPC: \(error)")
                    keyRequest.processContentKeyResponseError(error)
                }
            }
        }.resume()
    }
    
    private func sendSPCToKeyServer(_ spc: Data, completion: @escaping (Data) -> Void) {
        var request = URLRequest(url: licenseURL)
        request.httpMethod = "POST"
        request.httpBody = spc
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("❌ License request failed: \(error)")
                return
            }
            guard let ckcData = data else {
                print("❌ No CKC data received")
                return
            }
            completion(ckcData)
        }.resume()
    }
    
    
}
