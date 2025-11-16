//
//  CalendarViewModel.swift
//  Learning
//
//  Created by Areeg Altaiyah on 29/04/1447 AH.
//

import Foundation
import SwiftUI
import Combine

enum DayStatus {
    case learned
    case frozen
    case todayPending
    case none
}

class CalendarViewModel: ObservableObject {
    @Published var currentDate: Date = Date()

    // Single source of truth: CSV histories
    @AppStorage("learnDatesString") private var learnDatesString: String = ""
    @AppStorage("freezeDatesString") private var freezeDatesString: String = ""

    private let calendar = Calendar.current

    // Month title formatter (unchanged)
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    // Stable yyyy-MM-dd formatter for comparisons
    private let keyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = .current
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    // Simple split helpers
    private func splitDates(_ s: String) -> [String] {
        s.split(separator: ",").map { String($0) }
    }

    // Computed Sets for fast lookup
    private var learnedSet: Set<String> {
        Set(splitDates(learnDatesString))
    }
    private var frozenSet: Set<String> {
        Set(splitDates(freezeDatesString))
    }

    var months: [Date] {
        guard let startDate = calendar.date(byAdding: .month, value: -6, to: currentDate),
              let endDate = calendar.date(byAdding: .month, value: 6, to: currentDate) else {
            return []
        }

        var dates: [Date] = []
        var current = startDate
        while current <= endDate {
            dates.append(current)
            current = calendar.date(byAdding: .month, value: 1, to: current)!
        }
        return dates
    }

    func daysInMonth(from date: Date) -> [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else {
            return []
        }

        var days: [Date] = []

        // Leading empty days
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let leadingEmptyDays = (firstWeekday - calendar.firstWeekday + 7) % 7
        days.append(contentsOf: Array(repeating: Date.distantPast, count: leadingEmptyDays))

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(date)
            }
        }

        return days
    }

    func weekDaySymbols() -> [String] {
        var symbols = calendar.shortWeekdaySymbols
        let weekdayShift = calendar.firstWeekday - 1
        if weekdayShift > 0 {
            symbols = Array(symbols[weekdayShift..<symbols.count] + symbols[0..<weekdayShift])
        }
        return symbols.map { $0.uppercased() }
    }

    func formattedMonth(from date: Date) -> String {
        return dateFormatter.string(from: date)
    }

    func isToday(_ date: Date) -> Bool {
        return calendar.isDate(date, inSameDayAs: Date())
    }

    func isPlaceholder(_ date: Date) -> Bool {
        return calendar.isDate(date, equalTo: Date.distantPast, toGranularity: .day)
    }

    func dayNumber(from date: Date) -> Int {
        return calendar.component(.day, from: date)
    }

    // MARK: - Status

    private func key(for date: Date) -> String {
        keyFormatter.string(from: date)
    }

    private var todayKey: String {
        key(for: Date())
    }

    func status(for date: Date) -> DayStatus {
        let k = key(for: date)

        // Use array-backed history only
        let learned = learnedSet
        let frozen = frozenSet

        if learned.contains(k) { return .learned }
        if frozen.contains(k) { return .frozen }

        if k == todayKey {
            // Today and neither learned nor frozen yet -> pending
            return .todayPending
        }
        return .none
    }
}
