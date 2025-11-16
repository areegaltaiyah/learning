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

    // Source-of-truth CSV histories used by CurrentDayViewModel/CalendarViewModel
    @AppStorage("freezeDatesString") var freezeDatesString: String = ""
    @AppStorage("learnDatesString") var learnDatesString: String = ""

    // Inactivity tracking (epoch seconds)
    @AppStorage("lastActivityTime") var lastActivityTime: Double = 0

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

        // Reset everything when duration changes
        resetAll()
    }

    func updateTopic(_ newTopic: String) {
        topic = newTopic
    }

    // Reset all progress
    func resetAll() {
        // Clear learned and freeze histories
        learnDatesString = ""
        freezeDatesString = ""

        // Reset inactivity timer so we don't immediately reset again
        lastActivityTime = Date().timeIntervalSince1970
    }

    // Call on app activation to enforce 32-hour inactivity reset
    func resetIfInactiveLongerThan32Hours() {
        let now = Date().timeIntervalSince1970
        // If we have never recorded activity, initialize it to now and return
        guard lastActivityTime > 0 else {
            lastActivityTime = now
            return
        }
        let elapsed = now - lastActivityTime
        let thirtyTwoHours: Double = 32 * 3600
        if elapsed > thirtyTwoHours {
            resetAll()
        }
    }
}
