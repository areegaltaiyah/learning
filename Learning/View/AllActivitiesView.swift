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

            switch status {
            case .todayPending:
                ZStack {
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(Color.orangecircle)
                        .glassEffect()
                    Text("\(viewModel.dayNumber(from: date))")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)

            case .learned:
             //   if viewModel.isToday(date) {
                    // Learned today circle
                    ZStack {
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundStyle(Color.darkOrange)
                            .glassEffect()
                        Text("\(viewModel.dayNumber(from: date))")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundStyle(.orangecircle)
                    }
                    .frame(maxWidth: .infinity)
                //}
//                else {
//                    // Other learned days: white text (as you had)
//                    Text("\(viewModel.dayNumber(from: date))")
//                        .font(.system(size: 24, weight: .medium))
//                        .frame(maxWidth: .infinity)
//                        .foregroundStyle(.white)
//                }

            case .frozen:
                // Frozen day: turqoisey circle
                ZStack {
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundStyle(Color.darkTurqoise)
                        .glassEffect()
                    Text("\(viewModel.dayNumber(from: date))")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(Color.turqoisey)
                }
                .frame(maxWidth: .infinity)

            case .none:
                Text("\(viewModel.dayNumber(from: date))")
                    .font(.system(size: 24, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.primary)
            }
        }
    }
}

#Preview {
    ScrollingCalendarView().preferredColorScheme(.dark)
}
