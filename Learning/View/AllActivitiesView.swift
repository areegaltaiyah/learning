//
//  ScrollingCalendarView.swift
//  Learning
//
//  Created by Areeg Altaiyah on 29/04/1447 AH.
//

import SwiftUI

struct ScrollingCalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @Environment(\.presentationMode) private var presentationMode

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
                }.padding(.top,17.9)
            }
            .navigationTitle(Text("All activities")
                .font(.system(size: 90, weight: .semibold)))
           
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.white)
                    }
                }
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
            ZStack {
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(Color.orangey).opacity(0.2)
                    .glassEffect()

                Text("\(viewModel.dayNumber(from: date))")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(Color.orange)
                    .padding(1)
            }
        }
    }
}

#Preview {
    ScrollingCalendarView().preferredColorScheme(.dark)
}
