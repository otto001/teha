//
//  SwiftUI+HexColor.swift
//  teha
//
//  Created by Matteo Ludwig on 23.12.22.
//

import Foundation
import SwiftUI

extension Color {
    init?(hex: String) {
        let hex = String(hex.trimmingPrefix("#"))
        guard hex.count == 6,
              let red = Int(hex.substring(start: 0, end: 2), radix: 16),
              let green = Int(hex.substring(start: 2, end: 4), radix: 16),
              let blue = Int(hex.substring(start: 4, end: 6), radix: 16) else {
            return nil
        }
        
        self.init(red: Double(red)/255, green: Double(green)/255, blue: Double(blue)/255)
    }
}
