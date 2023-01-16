//
//  CGRect+Utils.swift
//  teha
//
//  Created by Matteo Ludwig on 15.01.23.
//

import Foundation
import CoreGraphics


extension CGRect {
    /// Returns the smallest rectangle that includes both given rectangles.
    /// - Parameter a: The first rectangle.
    /// - Parameter b: The second rectangle.
    /// - Returns: The smallest rectangle that includes both given rectangles.
    static func bounding(a: CGRect, b: CGRect) -> CGRect {
        let origin = CGPoint(x: min(a.minX, b.minX),
                             y: min(a.minY, b.minY))
        let size = CGSize(width: max(a.maxX, b.maxX) - origin.x, height: max(a.maxY, b.maxY) - origin.y)
        return CGRect(origin: origin, size: size)
    }
}

