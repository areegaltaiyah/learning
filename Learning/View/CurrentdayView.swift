//
//  CurrentdayView.swift
//  Learning
//
//  Created by Areeg Altaiyah on 26/04/1447 AH.
//
import SwiftUI

struct CurrentdayView: View {
    var body: some View {
        NavigationStack {
            VStack{
                CurrentNavigation()
                Spacer().frame(height: 24)
                //Card
                CurrentCard()
                
                Spacer().frame(height: 32)
                
                //BUTTON LOG AS LEARNED
                LearnedBIGbutton()
               
                Spacer().frame(height: 32)
                
                // BUTTON LOG AS FREEZED (dynamic enable/disable)
                FreezedbuttonDynamic()
                
                freezesUsed()
            }
        }
    }
}
//-------------------------Structs---------------------
//Card Struct
struct CurrentCard: View {
    var body: some View {
        GlassEffectContainer {
            HStack {
                VStack (alignment:.leading) {
                    CalendarHorizontalView()
                    Spacer().frame(height: 12)
                    Divider()
                    Spacer().frame(height: 11.5)
                    Learningtopic()
                    Spacer().frame(height: 12)

                    HStack{
                        Spacer()
                        //Days learned
                        DaysLearned()
                        
                        Spacer().frame(width:13)

                        //Days freezed
                        DaysFreezed()
                        Spacer()
                    }
                    Spacer().frame(height: 12)
                }
            }
        }
        .glassEffect(.clear,in:.rect(cornerRadius: 10))
    }
}
// Learning (topic) Text
struct Learningtopic: View {
    @AppStorage("topic") private var topic: String = ""
    
    var body: some View {
        Text("Learning \(topic.isEmpty ? "…" : topic)")
            .bold()
            .padding(.horizontal)
    }
}
//Navigation bar
struct CurrentNavigation: View {
    var body: some View {
        HStack(spacing:10){
            Text("Activity").bold().font(Font.largeTitle)
            Spacer()
            NavigationLink (destination: ScrollingCalendarView()) {
                Image(systemName: "calendar")
                    .font(Font.system(size: 20))
                    .foregroundStyle(.white)
                    .frame(width:44 ,height: 44)
                    .glassEffect()
            }
                
            NavigationLink (destination: LearningGoalView()) {
                Image(systemName: "pencil.and.outline")
                    .font(Font.system(size: 20))
                    .foregroundStyle(.white)
                    .frame(width:44 ,height: 44)
                    .glassEffect()
            }
        }
    }
}

//Calendar Struct
struct CalendarHorizontalView: View {
    @State private var currentDate = Date()
    // Keep a Date for the weekly view base
    @State private var date = Date()
    @State private var showingDatePicker = false

    // Custom month/year wheel state
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date()) - 1 // 0...11
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
 
    private var monthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }
    
    private var weekDays: [String] {
        let formatter = DateFormatter()
        return formatter.shortWeekdaySymbols // ["Sun","Mon",...]
    }
    
    private var weekDates: [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(monthYear).bold()
                Button(action: {
                    // Initialize wheels from currentDate whenever opening
                    let comps = Calendar.current.dateComponents([.year, .month], from: currentDate)
                    selectedMonth = (comps.month ?? 1) - 1
                    selectedYear = comps.year ?? selectedYear
                    showingDatePicker = true
                }) {
                    Image(systemName: showingDatePicker ? "chevron.down" : "chevron.right")
                        .foregroundColor(.orange)
                        .bold()
                }
                .popover(isPresented: $showingDatePicker, arrowEdge: .top) {
                    VStack(spacing: 16) {
                        HStack(spacing:0) {
                            // Month wheel
                            Picker("Month", selection: $selectedMonth) {
                                ForEach(0..<12, id: \.self) { index in
                                    Text(DateFormatter().monthSymbols[index]).tag(index)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)

                            // Year wheel (before 2025 and forward, default to current year)
                            let currentYear = Calendar.current.component(.year, from: Date())
                            let lowerBoundYear = 1900 // adjust as needed
                            Picker("Year", selection: $selectedYear) {
                                ForEach(lowerBoundYear...(currentYear + 50), id: \.self) { year in
                                    // Force plain string to avoid locale grouping separators like "2,025"
                                    Text(String(year)).tag(year)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                        }
                        .labelsHidden()
                        .onChange(of: selectedMonth) { _, _ in
                            applyMonthYearSelection()
                        }
                        .onChange(of: selectedYear) { _, _ in
                            applyMonthYearSelection()
                        }
                    }
                    .presentationCompactAdaptation(.popover)
                    .padding()
                }
                Spacer()
                
                Button(action: { moveMonth(-1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.orange)
                        .bold()
                }
                Spacer().frame(width: 28)
                
                Button(action: { moveMonth(1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.orange)
                        .bold()
                }
            }
            
            Spacer().frame(height: 15)
            
            HStack(spacing: 9) {
                ForEach(0..<7, id: \.self) { index in
                    let date = weekDates[index]
                    VStack {
                        Text(weekDays[Calendar.current.component(.weekday, from: date) - 1])
                            .foregroundColor(Color.greyish)
                            .bold()
                            .font(.subheadline)
                        
                        Text("\(Calendar.current.component(.day, from: date))")
                            .foregroundColor(Color.turqoisey)
                            .bold()
                            .font(.system(size: 25))
                            .frame(width: 44,height:44)
                            .background(
                                Circle().fill(Color.darkTurqoise)
                            )
                    }
                }
            }
        }
        .padding()
        // Keep the legacy date binding in sync if used elsewhere
        .onChange(of: currentDate) { _, newValue in
            date = firstDayOfMonth(for: newValue)
        }
    }
    
    private func moveMonth(_ value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentDate) {
            currentDate = firstDayOfMonth(for: newDate)
            // Keep the wheels in sync too
            let comps = Calendar.current.dateComponents([.year, .month], from: currentDate)
            selectedMonth = (comps.month ?? 1) - 1
            selectedYear = comps.year ?? selectedYear
        }
    }
    
    private func firstDayOfMonth(for date: Date) -> Date {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: comps) ?? date
    }

    private func applyMonthYearSelection() {
        var comps = DateComponents()
        comps.year = selectedYear
        comps.month = selectedMonth + 1 // DateComponents months are 1-based
        comps.day = 1
        if let composed = Calendar.current.date(from: comps) {
            currentDate = composed
        }
    }
}

//Days Learned Struct
struct DaysLearned: View{
    var body: some View{
        HStack{
            Spacer().frame(width: 12)
            Image(systemName: "flame.fill").foregroundStyle(Color.orange).font(Font.system(size: 20))
            VStack(alignment:.leading){
                Text("3").bold().font(.system(size: 24))
                Text("Days Learned").font(.system(size: 12))
                Spacer().frame(height: 6)
            }.frame(width: 78,height: 49)
            Spacer().frame(width: 12)
        }
        .frame(width: 180 ,height:79)
        .glassEffect(.clear.tint(Color.orangey.opacity(0.35)))
    }
}

//Days Freezed Struct
struct DaysFreezed: View{
    @AppStorage("freezesUsedCount") var freezesUsedCount = 0
    @AppStorage("freezes") var freezes: Int = 2

    var body: some View{
        HStack{
            Spacer().frame(width: 14)
            Image(systemName: "cube.fill").foregroundStyle(Color.turqoisey).font(Font.system(size: 20))
            VStack(alignment:.leading){
                Text("\(freezesUsedCount)").bold().font(.system(size: 24))
                Text("Days Freezed").font(.system(size: 12))
                Spacer().frame(height: 6)
            }.frame(width: 78,height: 49)
            Spacer().frame(width: 14)
        }
        .frame(width: 180 ,height:79)
        .glassEffect(.regular.tint(Color.turqoisey.opacity(0.2)))
    }
}

// ---------HUGE BUTTONS---------

//Log as Learned button
struct LearnedBIGbutton : View{
    var body: some View{
        Button("Log as\nLearned") {
            /* Action */
        }
        .bold()
        .foregroundStyle(Color.white)
        .font(.system(size: 36))
        .frame(width:274,height:274)
        .background(
            Circle()
                .fill(Color.orangey.opacity(0.95))
                .glassEffect(.clear.interactive())
        )
    }
}

//Learned today button
struct LearnedTodayBIGbutton : View{
    var body: some View{
        Button("Learned Today") {
            /* Action */
        }
        .bold()
        .foregroundStyle(Color.orange)
        .font(.system(size: 38))
        .padding(100)
        .background(
            Circle()
                .fill(Color.flameBG.opacity(0.95))
                .glassEffect(.clear.interactive())
        )
    }
}

//Day freezed button
struct DayFreezedBIGbutton : View{
    var body: some View{
        Button("Day Freezed") {
            /* Action */
        }
        .bold()
        .foregroundStyle(Color.turqoisey)
        .font(.system(size: 38))
        .padding(100)
        .background(
            Circle()
                .fill(Color.blackTurq.opacity(0.95))
                .glassEffect(.clear.interactive())
        )
    }
}

//----------- WELL DONE GOAL COMPLETED----------
struct WellDone: View{
    var body: some View{
        VStack(alignment:.center){
            Image(systemName: "hands.and.sparkles.fill").foregroundStyle(Color.orange)
                .font(Font.system(size: 40))
                .padding(1)
            Text("Well Done!")
                .bold()
                .font(Font.system(size: 22))
            Spacer().frame(height: 4)
            Text("Goal completed! start learning again or set new learning goal")
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .foregroundStyle(Color.greyish)
                .font(Font.system(size: 18))
                .fontWeight(.medium)
        }
        .padding(24)
    }
}

// ---------SMALL BUTTON---------

// Helper for stable yyyy-MM-dd key
private func todayKey() -> String {
    let formatter = DateFormatter()
    formatter.calendar = Calendar.current
    formatter.locale = .current
    formatter.timeZone = .current
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: Date())
}

struct FreezedbuttonDynamic: View {
    @AppStorage("freezesUsedCount") var freezesUsedCount = 0
    @AppStorage("freezes") var freezes: Int = 2
    @AppStorage("lastFreezeDate") private var lastFreezeDate: String = ""

    var body: some View {
        let key = todayKey()
        let alreadyLoggedToday = lastFreezeDate == key || freezesUsedCount >= freezes

        if alreadyLoggedToday {
            FreezedbuttonOFF()
        } else {
            Freezedbutton()
        }
    }
}

//Log as freezed
struct Freezedbutton: View {
    @AppStorage("freezesUsedCount") var freezesUsedCount = 0
    @AppStorage("freezes") var freezes: Int = 2
    @AppStorage("lastFreezeDate") private var lastFreezeDate: String = ""

    var body: some View {
        Button("Log as Freezed") {
            guard freezesUsedCount < freezes else { return }
            freezesUsedCount += 1
            lastFreezeDate = todayKey()
        }
        .foregroundStyle(Color.white)
        .font(.system(size: 17))
        .frame(width: 274, height: 48)
        .glassEffect(.regular.tint(Color.turqoisey.opacity(0.65)).interactive())
    }
}

//Log as freezed OFF
struct FreezedbuttonOFF : View{
    var body: some View{
        Button("Log as Freezed") {
            // disabled
        }
        .foregroundStyle(Color.white)
        .font(.system(size: 17))
        .frame(width: 274,height:48)
        .glassEffect(.regular.tint(Color.darkTurqoise.opacity(0.4)).interactive())
    }
}

//Set a new learning goal
struct SetlearningGoal: View {
    var body: some View{
        Button("Set new learning goal") {
            /* Action */
        }
        .foregroundStyle(Color.white)
        .font(.system(size: 17))
        .frame(width: 274,height:48)
        .glassEffect(.regular.tint(Color.orangey.opacity(0.95)).interactive())
    }
}

struct freezesUsed : View {
    @AppStorage("freezesUsedCount") var freezesUsedCount = 0
    @AppStorage("freezes") var freezes: Int = 2
    
    var body: some View{
        Text("\(freezesUsedCount) out of \(freezes) Freezes used")
            .font(Font.system(size: 14))
            .foregroundStyle(Color.greyish)
    }
}

#Preview {
    CurrentdayView().preferredColorScheme(.dark)
}
