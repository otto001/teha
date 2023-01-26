//
//  TimeInterval+Values.swift
//  teha
//
//  Created by Matteo Ludwig on 18.01.23.
//

import Foundation


extension TimeInterval {
    // some convenience static values for TimeInterval
    
    /// One week in seconds
    static let week: TimeInterval = TimeInterval(exactly: 7*24*60*60)!
    
    /// One day in seconds
    static let day: TimeInterval = TimeInterval(exactly: 24*60*60)!
    
    /// One hour in seconds
    static let hour: TimeInterval = TimeInterval(exactly: 60*60)!
    
    /// One minute in seconds
    static let minute: TimeInterval = TimeInterval(exactly: 60)!
}
