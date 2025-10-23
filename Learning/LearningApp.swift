//
//  LearningApp.swift
//  Learning
//
//  Created by Areeg Altaiyah on 24/04/1447 AH.
//

import SwiftUI

@main
struct LearningApp: App {
    @StateObject private var onboardingViewModel = OnboardingViewModel()

    var body: some Scene {
        WindowGroup {
            OnboardingView()
                .environmentObject(onboardingViewModel)
        }
    }
}
