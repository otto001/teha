//
//  String+Substring.swift
//  teha
//
//  Created by Matteo Ludwig on 23.12.22.
//

import Foundation


extension String {
    
    ///Returns an index that is the specified distance from the startIndex.
    /// - Parameter offsetFromStart: The distance to offset the startIndex.
    /// - Returns: An index offset by offsetFromStart from the startIndex
    func index(offsetFromStart distance: Int) -> Index {
        return self.index(self.startIndex, offsetBy: distance)
    }
    
    /// Returns a substring from start to end (end not included).
    /// - Parameter start: The first index included in the result.
    /// - Parameter end: The first index to not be included in the result.
    /// - Returns: A Substring from start to end.
    func substring(start: Int, end: Int) -> Substring {
        return self[index(offsetFromStart: start)..<index(offsetFromStart: end)]
    }
}
