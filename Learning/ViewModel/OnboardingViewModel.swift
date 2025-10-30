//
//  OnboardingViewModel.swift
//  Learning
//
//  Created by Areeg Altaiyah on 30/04/1447 AH.
//

import SwiftUI
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {
    @AppStorage("freezes") var freezes: Int = 2
    @AppStorage("selectedDuration") var selectedDuration: String = ("Week")
    @AppStorage("topic") var topic: String = ""
    @AppStorage("freezesUsedCount") var freezesUsedCount = 0
    @AppStorage("daysLearnedCount") var daysLearnedCount = 0
    @AppStorage("lastFreezeDate") var lastFreezeDate: String = "" // reset when goal changes
    @AppStorage("lastLearnDate") var lastLearnDate: String = ""   // add to manage progress reset

    var goal: LearningGoal {
        LearningGoal(topic: topic, duration: selectedDuration, freezes: freezes)
    }
       
    func updateDuration(_ duration: String) {
        selectedDuration = duration
        switch duration {
        case "Week":
            freezes = 2
        case "Month":
            freezes = 8
        case "Year":
            freezes = 96
        default:
            freezes = 0
        }
        
        // Reset used freezes whenever the goal duration changes
        freezesUsedCount = 0
        
        // Also clear "froze today" marker to re-enable the button immediately
        lastFreezeDate = ""
    }
       
    func updateTopic(_ newTopic: String) {
        topic = newTopic
    }

    // Call this when user confirms "Update" in LearningGoalView
    func resetProgress() {
        // Reset learning streak/progress
        daysLearnedCount = 0
        lastLearnDate = ""
        // Reset any freeze tracking too for a clean start
        freezesUsedCount = 0
        lastFreezeDate = ""
    }
}
