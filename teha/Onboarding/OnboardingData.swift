//
//  OnboardingData.swift
//  teha
//
//  Created by Guest User on 17.01.23.
//

import SwiftUI

struct OnboardingData: Hashable, Identifiable {
    let id: Int
    let image: String
    let text: String
    
    static let list: [OnboardingData] = [
    OnboardingData(id: 0, image: String(localized: "screenshot-tasks"), text: String(localized: "onboarding-tasks")),
    OnboardingData(id: 1, image: String(localized: "screenshot-projects"), text: String(localized: "onboarding-projects"))]
}

