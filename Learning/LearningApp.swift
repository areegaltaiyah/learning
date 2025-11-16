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
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            OnboardingView()
                .environmentObject(onboardingViewModel)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // Check inactivity every time app becomes active
                onboardingViewModel.resetIfInactiveLongerThan32Hours()
            }
        }
    }
}

