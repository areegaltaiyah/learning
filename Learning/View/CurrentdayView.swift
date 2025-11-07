//
//  CurrentdayView.swift
//  Learning
//
//  Created by Areeg Altaiyah on 26/04/1447 AH.
//
import SwiftUI

struct CurrentdayView: View {
    
    // ------ViewModels------
    @StateObject private var currentDayvm = CurrentDayViewModel()
    @StateObject private var calendarVM = CalendarViewModel()
    @AppStorage("selectedDuration") private var selectedDuration: String = "Week"
    
    // Observe the string-backed histories so the view refreshes when they are reset in LearningGoalView
    @AppStorage("learnDatesString") private var learnDatesString: String = ""
    @AppStorage("freezeDatesString") private var freezeDatesString: String = ""

    private var goalDurationDays: Int {
        switch selectedDuration {
        case "Week": return 7
        case "Month": return 30
        case "Year": return 365
        default: return 0
        }
    }

    private var goalCompleted: Bool {
        (currentDayvm.daysLearnedCount + currentDayvm.freezesUsedCount) >= goalDurationDays && goalDurationDays > 0
    }

    var body: some View {
        NavigationStack {
            VStack{
                CurrentNavigation()
                Spacer().frame(height: 24)

                // Card
                CurrentCard(viewModel: calendarVM)
                
                Spacer().frame(height: 32)
                
                // BIG BUTTON
                
                if goalCompleted {
                    WellDone()
                } else {
                    switch currentDayvm.todayState {
                    case .learnedToday:
                        LearnedTodayBIGbutton()
                    case .frozenToday:
                        DayFreezedBIGbutton()
                    case .normal, .noFreezesLeft:
                        LearnedBIGbutton(action: {
                            currentDayvm.logLearnedToday()
                        })
                    }
                }
               
                Spacer().frame(height: 32)
                
                // SMALL BUTTON
                
                if goalCompleted {
                    SetlearningGoal()
                } else {
                    switch currentDayvm.todayState {
                    case .normal:
                        Freezedbutton(action: {
                            currentDayvm.logFreezedToday()
                        })
                    case .learnedToday, .frozenToday, .noFreezesLeft:
                        FreezedbuttonOFF()
                    }
                }

                // Freezes count: hide when goal is completed
                if !goalCompleted {
                    freezesUsedView(
                        usedCount: currentDayvm.freezesUsedCount,
                        total: currentDayvm.freezesLimit
                    )
                }
            }
            .onAppear {
                currentDayvm.recomputeTodayState()
            }
            // If goal duration changes, recompute the state
            .onChange(of: selectedDuration) { _, _ in
                currentDayvm.recomputeTodayState()
            }
            // If histories are reset in LearningGoalView, recompute and the UI will switch back from "Well Done"
            .onChange(of: learnDatesString) { _, _ in
                currentDayvm.recomputeTodayState()
            }
            .onChange(of: freezeDatesString) { _, _ in
                currentDayvm.recomputeTodayState()
            }
            // Also observe counters directly to ensure immediate UI updates
            .onChange(of: currentDayvm.daysLearnedCount) { _, _ in
                currentDayvm.recomputeTodayState()
            }
            .onChange(of: currentDayvm.freezesUsedCount) { _, _ in
                currentDayvm.recomputeTodayState()
            }
        }
    }
}



// Text of remaining freezes 
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
    // Inject OnboardingViewModel so LearningGoalView destinations are safe in preview
    CurrentdayView()
        .preferredColorScheme(.dark)
        .environmentObject(OnboardingViewModel())
}
