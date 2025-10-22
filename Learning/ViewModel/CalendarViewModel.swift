//
//  CalendarViewModel.swift
//  Learning
//
//  Created by Areeg Altaiyah on 29/04/1447 AH.
//


//
//  CalendarViewModel.swift
//  Learning Tracking App
//
//  Created by Suhaylah hawsawi on 27/04/1447 AH.
//

import Foundation
import SwiftUI
import Combine


class CalendarViewModel: ObservableObject {
    @Published var currentDate: Date = Date()

    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

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
}
