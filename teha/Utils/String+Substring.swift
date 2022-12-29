//
//  String+Substring.swift
//  teha
//
//  Created by Matteo Ludwig on 23.12.22.
//

import Foundation


extension String {
    
    func substring(start: Int, end: Int) -> Substring {
        return self[index(startIndex, offsetBy: start)..<index(startIndex, offsetBy: end)]
    }
}
