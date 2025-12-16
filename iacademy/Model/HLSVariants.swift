//
//  HLSVariants.swift
//  iacademy
//
//  Created by Marwan Osama on 13/12/2025.
//

import Foundation

struct HLSVariant: Codable {
    let resolution: String?
    let bandwidth: Int?
    let url: URL
    
    static func parseVariants(from playlist: String, baseURL: URL) -> [HLSVariant] {
        var variants: [HLSVariant] = []
        let lines = playlist.components(separatedBy: "\n")
        
        for (index, line) in lines.enumerated() {
            if line.hasPrefix("#EXT-X-STREAM-INF") {
                let resolution = line.slice(between: "RESOLUTION=", and: ",") ??
                                 line.slice(between: "RESOLUTION=", and: nil)
                let bandwidthStr = line.slice(between: "BANDWIDTH=", and: ",") ??
                                   line.slice(between: "BANDWIDTH=", and: nil)
                let bandwidth = bandwidthStr.flatMap { Int($0) }
                
                if index + 1 < lines.count {
                    let uriLine = lines[index + 1].trimmingCharacters(in: .whitespacesAndNewlines.union(.controlCharacters))
                    if let variantURL = URL(string: uriLine, relativeTo: baseURL) {
                        variants.append(HLSVariant(resolution: resolution, bandwidth: bandwidth, url: variantURL))
                    }
                }
            }
        }
        return variants
    }
}
