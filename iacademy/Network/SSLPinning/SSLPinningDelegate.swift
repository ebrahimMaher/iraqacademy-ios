//
//  SSLPinningDelegate.swift
//  iacademy
//
//  Created by Marwan Osama on 23/01/2026.
//

import Foundation

final class SSLPinningDelegate: NSObject, URLSessionDelegate {

    private let pinnedCertificates: [Data]
    private let lock = DispatchQueue(label: "ssl.pinning.lock")

    private var _pinningError: SSLPinningError?
    var pinningError: SSLPinningError? {
        lock.sync { _pinningError }
    }

    init(certNames: [String]) {
        self.pinnedCertificates = certNames.compactMap {
            guard let url = Bundle.main.url(forResource: $0, withExtension: "cer"),
                  let data = try? Data(contentsOf: url) else {
                return nil
            }
            return data
        }
        super.init()
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {

        lock.sync { _pinningError = nil }

        guard
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust
        else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        let serverCertificates = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate] ?? []

        for certificate in serverCertificates {
            let serverCertData = SecCertificateCopyData(certificate) as Data
            if pinnedCertificates.contains(serverCertData) {
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
                return
            }
        }

        lock.sync { _pinningError = .failed }
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}

