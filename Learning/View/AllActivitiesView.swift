//
//  ScrollingCalendarView.swift
//  Learning
//
//  Created by Areeg Altaiyah on 29/04/1447 AH.
//

import SwiftUI

struct ScrollingCalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var navigateBack = false

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                // ------Calendar UI------
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.months.enumerated()), id: \.offset) { (_, monthStart) in
                        CalendarMonthView(viewModel: viewModel, monthStart: monthStart)
                            .frame(width: 338)

                        Spacer().frame(height: 8)

                        Rectangle()
                            .frame(height: 0.5)
                            .padding(.horizontal, 28)
                            .foregroundStyle(Color.greyish)

                        Spacer().frame(height: 24)
                    }
                }
                .padding(.top,17.9)
            }
            // ------NAVIGATION------

            .navigationTitle(Text("All activities")
                .font(.system(size: 90, weight: .semibold)))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        navigateBack = true
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.white)
                    }
                }
            }
            .navigationDestination(isPresented: $navigateBack) {
                CurrentdayView()
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

// ------STRUCTS-----

struct CalendarMonthView: View {
    let viewModel: CalendarViewModel
    let monthStart: Date

    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.formattedMonth(from: monthStart))
                .font(.system(size: 17, weight: .semibold))
            Spacer().frame(height: 8)
            CalendarWeekHeaderView(weekDays: viewModel.weekDaySymbols())

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(viewModel.daysInMonth(from: monthStart), id: \.self) { date in
                    CalendarDayView(viewModel: viewModel, date: date)
                }
            }
        }
    }
}

struct CalendarWeekHeaderView: View {
    let weekDays: [String]

    var body: some View {
        HStack {
            ForEach(weekDays, id: \.self) { day in
                Text(day)
                    .font(.system(size: 13, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct CalendarDayView: View {
    let viewModel: CalendarViewModel
    let date: Date

    var body: some View {
        if viewModel.isPlaceholder(date) {
            Text("")
                .frame(maxWidth: .infinity)
        } else {
            let status = viewModel.status(for: date)
            DayStatusBadge(
                status: status,
                dayNumber: viewModel.dayNumber(from: date),
                size: 40
            )
            .frame(maxWidth: .infinity)
        }
    }
}

// ------Reusable status badge------

struct DayStatusBadge: View {
    let status: DayStatus
    let dayNumber: Int
    let size: CGFloat

    var body: some View {
        switch status {
        case .todayPending:
            ZStack {
                Circle()
                    .frame(width: size, height: size)
                    .foregroundStyle(Color.orangecircle)
                    .glassEffect()
                Text("\(dayNumber)")
                    .font(.system(size: fontSize, weight: .medium))
                    .foregroundStyle(.white)
            }

        case .learned:
            ZStack {
                Circle()
                    .frame(width: size, height: size)
                    .foregroundStyle(Color.darkOrange)
                    .glassEffect()
                Text("\(dayNumber)")
                    .font(.system(size: fontSize, weight: .medium))
                    .foregroundStyle(Color.orangecircle)
            }

        case .frozen:
            ZStack {
                Circle()
                    .frame(width: size, height: size)
                    .foregroundStyle(Color.darkTurqoise)
                    .glassEffect()
                Text("\(dayNumber)")
                    .font(.system(size: fontSize, weight: .medium))
                    .foregroundStyle(Color.turqoisey)
            }

        case .none:
            Text("\(dayNumber)")
                .font(.system(size: fontSize, weight: .medium))
                .foregroundStyle(.primary)
                .frame(width: size, height: size)
        }
    }

    // Simple mapping to keep text size visually balanced with circle size
    private var fontSize: CGFloat {
        // Original designs used 24 for 40pt, 25 for 44pt; keep close
        if size <= 40 { return 24 }
        if size <= 44 { return 25 }
        return max(24, size * 0.6)
    }
}

#Preview {
    ScrollingCalendarView().preferredColorScheme(.dark)
}
