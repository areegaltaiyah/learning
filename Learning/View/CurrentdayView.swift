//
//  CurrentdayView.swift
//  Learning
//
//  Created by Areeg Altaiyah on 26/04/1447 AH.
//
import SwiftUI

// Local JSON helpers (no new files)
private let jsonEncoder = JSONEncoder()
private let jsonDecoder = JSONDecoder()

private func encodeArray(_ array: [String]) -> Data {
    (try? jsonEncoder.encode(array)) ?? Data()
}
private func decodeArray(_ data: Data) -> [String] {
    (try? jsonDecoder.decode([String].self, from: data)) ?? []
}

private enum TodayState {
    case normal            // can learn, can freeze (if any left)
    case learnedToday      // today is already logged as learned
    case frozenToday       // today is already frozen
    case noFreezesLeft     // user has exhausted freezes (today not frozen/learned)
}

struct CurrentdayView: View {
    // Legacy single-day storage (kept for migration/compatibility)
    @AppStorage("lastFreezeDate") private var lastFreezeDate: String = ""
    @AppStorage("freezesUsedCount") private var freezesUsedCount: Int = 0
    @AppStorage("freezes") private var freezes: Int = 2

    @AppStorage("lastLearnDate") private var lastLearnDate: String = ""
    @AppStorage("daysLearnedCount") private var daysLearnedCount: Int = 0

    // New JSON-backed arrays (kept in this file only)
    @AppStorage("freezeDatesData") private var freezeDatesData: Data = Data()
    @AppStorage("learnDatesData") private var learnDatesData: Data = Data()

    // Computed accessors for arrays
    private var freezeDates: [String] {
        get { decodeArray(freezeDatesData) }
        nonmutating set { freezeDatesData = encodeArray(newValue) }
    }
    private var learnDates: [String] {
        get { decodeArray(learnDatesData) }
        nonmutating set { learnDatesData = encodeArray(newValue) }
    }

    // One-time migration flag
    @AppStorage("didMigrateSingleDatesToArrays") private var didMigrateSingleDatesToArrays: Bool = false

    // Calendar status source for the horizontal calendar (matches AllActivities)
    @StateObject private var calendarVM = CalendarViewModel()

    private var todayState: TodayState {
        let key = todayKey()
        // Learned takes precedence visually
        if learnDates.contains(key) {
            return .learnedToday
        } else if freezeDates.contains(key) {
            return .frozenToday
        } else if freezeDates.count >= freezes {
            return .noFreezesLeft
        } else {
            return .normal
        }
    }

    var body: some View {
        NavigationStack {
            VStack{
                CurrentNavigation()
                Spacer().frame(height: 24)

                // Card
                CurrentCard(viewModel: calendarVM)
                
                Spacer().frame(height: 32)
                
                // BIG BUTTON: driven by todayState
                switch todayState {
                case .learnedToday:
                    LearnedTodayBIGbutton()
                case .frozenToday:
                    DayFreezedBIGbutton()
                case .normal, .noFreezesLeft:
                    // Pass bindings so the button can update arrays and counts
                    LearnedBIGbutton(
                        learnDates: Binding(
                            get: { learnDates },
                            set: { new in
                                learnDates = new
                                // Keep counter in sync with history
                                daysLearnedCount = learnDates.count
                                // Keep legacy lastLearnDate for compatibility
                                lastLearnDate = learnDates.last ?? lastLearnDate
                            }
                        )
                    )
                }
               
                Spacer().frame(height: 32)
                
                // Small "Log as Freezed" button: enabled only in .normal
                switch todayState {
                case .normal:
                    Freezedbutton(
                        freezeDates: Binding(
                            get: { freezeDates },
                            set: { new in
                                freezeDates = new
                                // Keep counter in sync with history
                                freezesUsedCount = freezeDates.count
                                // Keep legacy lastFreezeDate for compatibility
                                lastFreezeDate = freezeDates.last ?? lastFreezeDate
                            }
                        ),
                        freezesLimit: freezes
                    )
                case .learnedToday, .frozenToday, .noFreezesLeft:
                    FreezedbuttonOFF()
                }

                freezesUsedView(
                    usedCount: freezeDates.count,
                    total: freezes
                )
            }
            .onAppear {
                migrateIfNeeded()
                // Ensure counters reflect arrays
                daysLearnedCount = learnDates.count
                freezesUsedCount = freezeDates.count
            }
        }
    }

    // Migrate legacy single-day keys into arrays (one time)
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

        // Sync counts
        freezesUsedCount = freezeDates.count
        daysLearnedCount = learnDates.count

        didMigrateSingleDatesToArrays = true
    }
}
//-------------------------Structs---------------------
//Card Struct
struct CurrentCard: View {
    let viewModel: CalendarViewModel

    var body: some View {
        GlassEffectContainer {
            HStack {
                VStack (alignment:.leading) {
                    CalendarHorizontalView(viewModel: viewModel)
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
        Text("Learning \(topic.isEmpty ? "Swift" : topic)")
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
    @ObservedObject var viewModel: CalendarViewModel

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
                    let status = viewModel.status(for: date)

                    VStack {
                        Text(weekDays[Calendar.current.component(.weekday, from: date) - 1])
                            .foregroundColor(Color.greyish)
                            .bold()
                            .font(.subheadline)

                        // Match AllActivities circles and styles
                        switch status {
                        case .todayPending:
                            ZStack {
                                Circle()
                                    .frame(width: 44, height: 44)
                                    .foregroundStyle(Color.orangecircle)
                                Text("\(Calendar.current.component(.day, from: date))")
                                    .font(.system(size: 25, weight: .medium))
                                    .foregroundStyle(.white)
                            }

                        case .learned:
                            ZStack {
                                Circle()
                                    .frame(width: 44, height: 44)
                                    .foregroundStyle(Color.darkOrange)
                                Text("\(Calendar.current.component(.day, from: date))")
                                    .font(.system(size: 25, weight: .medium))
                                    .foregroundStyle(Color.orangecircle)
                            }

                        case .frozen:
                            ZStack {
                                Circle()
                                    .frame(width: 44, height: 44)
                                    .foregroundStyle(Color.darkTurqoise)
                                Text("\(Calendar.current.component(.day, from: date))")
                                    .font(.system(size: 25, weight: .medium))
                                    .foregroundStyle(Color.turqoisey)
                            }

                        case .none:
                            Text("\(Calendar.current.component(.day, from: date))")
                                .bold()
                                .font(.system(size: 25))
                                .frame(width: 44, height: 44)
                              
                        }
                    }
                }
            }
        }
        .padding()
        
        .onChange(of: currentDate) { _, newValue in
            date = firstDayOfMonth(for: newValue)
        }
    }
    
    private func moveMonth(_ value: Int) {
        if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: value, to: currentDate) {
            currentDate = newDate
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
    // Keep showing the synchronized counter (synced from learnDates.count)
    @AppStorage("daysLearnedCount") var daysLearnedCount: Int = 0

    var body: some View{
        HStack{
            Spacer().frame(width: 12)
            Image(systemName: "flame.fill").foregroundStyle(Color.orange).font(Font.system(size: 20))
            VStack(alignment:.leading){
                Text("\(daysLearnedCount)").bold().font(.system(size: 24))
                
                Text(daysLearnedCount == 1 ? "Day Learned" : "Days Learned").font(.system(size: 12))
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
    // Keep showing the synchronized counter (synced from freezeDates.count)
    @AppStorage("freezesUsedCount") var freezesUsedCount = 0
    @AppStorage("freezes") var freezes: Int = 2

    var body: some View{
        HStack{
            Spacer().frame(width: 14)
            Image(systemName: "cube.fill").foregroundStyle(Color.turqoisey).font(Font.system(size: 20))
            VStack(alignment:.leading){
                Text("\(freezesUsedCount)").bold().font(.system(size: 24))
                Text(freezesUsedCount == 1 ? "Day Freezed" : "Days Freezed").font(.system(size: 12))
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
    // We receive learnDates via Binding so we can update the array and let parent sync counts.
    @Binding var learnDates: [String]

    var body: some View{
        Button("Log as\nLearned") {
            let key = todayKey()
            if !learnDates.contains(key) {
                learnDates.append(key)
            }
        }
        .bold()
        .foregroundStyle(Color.white)
        .font(.system(size: 38))
        .frame(width:274,height:274)
        .background(
            Circle()
                .fill(Color.orangey.opacity(0.95))
                .glassEffect(.clear.interactive())
        )
    }
}

//Learned today button (read-only)
struct LearnedTodayBIGbutton : View{
    var body: some View{
        Button("Learned\nToday") {
            // no-op; already logged for today
        }
        .bold()
        .foregroundStyle(Color.orange)
        .font(.system(size: 36))
        .frame(width:274,height:274)
        .background(
            Circle()
                .fill(Color.flameBG.opacity(0.95))
                .glassEffect(.clear.interactive())
        )
    }
}

//Day freezed button (read-only)
struct DayFreezedBIGbutton : View{
    var body: some View{
        Button("Day\nFreezed") {
            // no-op; already frozen for today
        }
        .bold()
        .foregroundStyle(Color.turqoisey)
        .font(.system(size: 38))
        .frame(width:274,height:274)
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

//Log as freezed (enabled)
struct Freezedbutton: View {
    // Receive and update the array; parent keeps counts in sync
    @Binding var freezeDates: [String]
    var freezesLimit: Int

    var body: some View {
        Button("Log as Freezed") {
            let key = todayKey()
            guard freezeDates.count < freezesLimit else { return }
            if !freezeDates.contains(key) {
                freezeDates.append(key)
            }
        }
        .foregroundStyle(Color.white)
        .font(.system(size: 17))
        .frame(width: 274, height: 48)
        .glassEffect(.regular.tint(Color.turqoisey.opacity(0.65)).interactive())
    }
}

//Log as freezed OFF (disabled)
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

// Text of remaining freezes 
// Converted to a standalone view function so we can pass the used count from arrays
@ViewBuilder
private func freezesUsedView(usedCount: Int, total: Int) -> some View {
    let usedWord = usedCount == 1 ? "Freeze" : "Freezes"
    let totalWord = total == 1 ? "Freeze" : "Freezes"
    Text("\(usedCount) out of \(total) \(totalWord) used")
        .font(Font.system(size: 14))
        .foregroundStyle(Color.greyish)
        .accessibilityLabel("\(usedCount) \(usedWord) out of \(total) \(totalWord) used")
}

#Preview {
    CurrentdayView().preferredColorScheme(.dark)
}

