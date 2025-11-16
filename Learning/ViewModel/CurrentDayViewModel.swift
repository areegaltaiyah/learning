import SwiftUI
import Combine

@MainActor
final class CurrentDayViewModel: ObservableObject {

    // Single source of truth: CSV histories
    @AppStorage("freezeDatesString") private var freezeDatesString: String = ""
    @AppStorage("learnDatesString") private var learnDatesString: String = ""

    // Settings
    @AppStorage("freezes") var freezesLimit: Int = 2
    @AppStorage("topic") var topic: String = ""

    // Inactivity tracking (shared key with OnboardingViewModel)
    @AppStorage("lastActivityTime") private var lastActivityTime: Double = 0

    // Published UI-facing state
    @Published private(set) var todayState: TodayState = .normal
    @Published private(set) var daysLearnedCount: Int = 0
    @Published private(set) var freezesUsedCount: Int = 0

    // Access arrays via comma-separated storage
    var freezeDates: [String] {
        get { fromStorageString(freezeDatesString) }
        set {
            freezeDatesString = toStorageString(newValue)
            syncCountersFromArrays()
        }
    }
    var learnDates: [String] {
        get { fromStorageString(learnDatesString) }
        set {
            learnDatesString = toStorageString(newValue)
            syncCountersFromArrays()
        }
    }

    init() {
        syncCountersFromArrays()
        recomputeTodayState()
    }

    // MARK: - Intent(s)

    func logLearnedToday() {
        let key = todayKey()
        guard !learnDates.contains(key) else { return }
        var updated = learnDates
        updated.append(key)
        learnDates = updated

        // Mark activity
        lastActivityTime = Date().timeIntervalSince1970

        recomputeTodayState()
    }

    func logFreezedToday() {
        let key = todayKey()
        guard freezeDates.count < freezesLimit else { return }
        guard !freezeDates.contains(key) else { return }
        var updated = freezeDates
        updated.append(key)
        freezeDates = updated

        // Mark activity
        lastActivityTime = Date().timeIntervalSince1970

        recomputeTodayState()
    }

    // MARK: - Derived state

    func recomputeTodayState() {
        let key = todayKey()
        if learnDates.contains(key) {
            todayState = .learnedToday
        } else if freezeDates.contains(key) {
            todayState = .frozenToday
        } else if freezeDates.count >= freezesLimit {
            todayState = .noFreezesLeft
        } else {
            todayState = .normal
        }
    }

    private func syncCountersFromArrays() {
        daysLearnedCount = learnDates.count
        freezesUsedCount = freezeDates.count
    }

    // Expose a refresh so views can pull latest from AppStorage after external resets
    func refreshFromStorage() {
        // Re-read arrays via getters (which read the AppStorage strings),
        // then update counters and state.
        _ = learnDates
        _ = freezeDates
        syncCountersFromArrays()
        recomputeTodayState()
    }
}

// MARK: - Simple helpers shared with the view

func toStorageString(_ array: [String]) -> String {
    array.joined(separator: ",")
}
func fromStorageString(_ string: String) -> [String] {
    string.split(separator: ",").map { String($0) }
}

func todayKey() -> String {
    let formatter = DateFormatter()
    formatter.calendar = Calendar.current
    formatter.locale = .current
    formatter.timeZone = .current
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: Date())
}

enum TodayState {
    case normal
    case learnedToday
    case frozenToday
    case noFreezesLeft
}
