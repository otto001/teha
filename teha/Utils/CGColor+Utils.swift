//
//  CGColor+Hex.swift
//  teha
//
//  Created by Andreas Romann and Matteo Ludwig on 10.01.23.
//

import Foundation
import CoreGraphics

//MARK: Hex
extension CGColor {
    /// The components of the color as a hexadecimal string in P3 color space.
    var hex: String? {
        return self.components?.map {
            String(format:"%02X", Int($0 * 255))
        }.joined()
    }

    /// Create a CGColor in P3 colorspace based on a hexadecimal string.
    /// - Returns: A CGColor based on the given hexadecimal string. Returns nil on failure.
    static func fromHex(_ string: String) -> CGColor? {
        let components: [CGFloat] = (0..<string.count/2).compactMap {
            let substr = string[string.index(string.startIndex, offsetBy: $0*2)..<string.index(string.startIndex, offsetBy: $0*2+2)]
            guard let int = Int(substr, radix: 16) else { return nil }
            return CGFloat(int) / 255
        }
        return CGColor(colorSpace: CGColorSpace(name: CGColorSpace.displayP3)!, components: components)
    }
}

