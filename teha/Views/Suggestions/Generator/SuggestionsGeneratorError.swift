//
//  SuggestionsGeneratorError.swift
//  teha
//
//  Created by Matteo Ludwig on 28.01.23.
//

import Foundation

/// The type of errors thrown by SuggestionsGenerator
enum SuggestionsGeneratorError: LocalizedError {
    /// The settings stored in UserDefault (see SuggestionsGenerator) are not valid (e.g. the start of day is before the end, or the user works 0 days per week)
    case badWorktimeSettings
    
    //TODO: The error messages are no quite clear: what if the user has tasks with deadlines and all, but they are in more than two weeks?
    /// There are no tasks within the next two weeks that teha can generate suggestions for
    case noCalculateableTasks
    
    /// Something went wrong and we have no idea what or why. Honestly, this error should not ever be thrown.
    case internalError
    
    var errorDescription: String? {
        switch self {
        case .badWorktimeSettings:
            return String(localized: "suggestions-bad-worktime-settings")
        case .noCalculateableTasks:
            return String(localized: "suggestions-no-calculateable-tasks")
        case .internalError:
            return String(localized: "internal-error")
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .badWorktimeSettings:
            return String(localized: "suggestions-bad-worktime-settings-recovery")
        case .noCalculateableTasks:
            return String(localized: "suggestions-no-calculateable-tasks-recovery")
        case .internalError:
            return String(localized: "internal-error-recovery")
        }
    }
}

