//
//  CGColor+Hex.swift
//  teha
//
//  Created by Second Dude on 10.01.23.
//

import Foundation
import CoreGraphics

extension CGColor {
    var hex: String? {
        return self.components?.map {
            String(format:"%02X", Int($0 * 255))
        }.joined()
    }

    static func fromHex(_ string: String) -> CGColor? {
        let components: [CGFloat] = (0..<string.count/2).compactMap {
            let substr = string.substring(start: $0*2, end: $0*2+2)
            guard let int = Int(substr, radix: 16) else { return nil }
            return CGFloat(int) / 255
        }
        switch components.count {
        case 4:
            return CGColor(red: components[0], green: components[1], blue: components[2], alpha: components[3])
        case 3:
            return CGColor(red: components[0], green: components[1], blue: components[2], alpha: 1)
        case 1:
            return CGColor(gray: components[0], alpha: 1)
        default:
            return nil
        }
        
    }
}


