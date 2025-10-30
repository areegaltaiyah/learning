import SwiftUI
import Combine

@MainActor
final class CurrentDayViewModel: ObservableObject {

    // Storage
    @AppStorage("lastFreezeDate") private var lastFreezeDate: String = ""
    @AppStorage("freezesUsedCount") private var freezesUsedCountStorage: Int = 0
    @AppStorage("freezes") var freezesLimit: Int = 2

    @AppStorage("lastLearnDate") private var lastLearnDate: String = ""
    @AppStorage("daysLearnedCount") private var daysLearnedCountStorage: Int = 0

    @AppStorage("freezeDatesString") private var freezeDatesString: String = ""
    @AppStorage("learnDatesString") private var learnDatesString: String = ""

    @AppStorage("didMigrateSingleDatesToArrays") private var didMigrateSingleDatesToArrays: Bool = false
    @AppStorage("topic") var topic: String = ""

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
        migrateIfNeeded()
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

        // Legacy compatibility
        lastLearnDate = key

        recomputeTodayState()
    }

    func logFreezedToday() {
        let key = todayKey()
        guard freezeDates.count < freezesLimit else { return }
        guard !freezeDates.contains(key) else { return }
        var updated = freezeDates
        updated.append(key)
        freezeDates = updated

        // Legacy compatibility
        lastFreezeDate = key

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

        // Keep legacy counters in sync
        daysLearnedCountStorage = daysLearnedCount
        freezesUsedCountStorage = freezesUsedCount

        // Keep legacy last dates in sync
        if let last = learnDates.last { lastLearnDate = last }
        if let last = freezeDates.last { lastFreezeDate = last }
    }

    // MARK: - Migration

    private func migrateIfNeeded() {
        guard !didMigrateSingleDatesToArrays else { return }

        var updatedFreeze = freezeDates
        var updatedLearn = learnDates

        if !lastFreezeDate.isEmpty && !updatedFreeze.contains(lastFreezeDate) {
            updatedFreeze.append(lastFreezeDate)
        }
        if !lastLearnDate.isEmpty && !updatedLearn.contains(lastLearnDate) {
            updatedLearn.append(lastLearnDate)
        }

        if updatedFreeze != freezeDates {
            freezeDates = updatedFreeze
        }
        if updatedLearn != learnDates {
            learnDates = updatedLearn
        }

        didMigrateSingleDatesToArrays = true
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
