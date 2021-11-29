//
//  sha256sum.swift
//  MyYearWithGit
//
//  Created by Lakr Aream on 2021/11/30.
//

import CommonCrypto
import Foundation

extension String {
    var sha256: String {
        let data = self.data(using: .utf8) ?? Data()
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &digest)
        }
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        let sha256Hex = hexBytes.joined()
        return sha256Hex
    }
}
