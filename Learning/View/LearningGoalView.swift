import SwiftUI

struct LearningGoalView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @State private var navigateBack = false
    @State private var navigateNext = false
    @State private var showCheckAlert = false

    var body: some View {
        NavigationStack {
            VStack {
                Spacer().frame(height: 32)
                UserGoal(viewModel: viewModel)
                    .padding(.horizontal)
                Spacer()
            }
            .navigationTitle("Learning Goal")
            .bold()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(
                        action: {
                            navigateBack = true
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                        }
                        .navigationDestination(isPresented: $navigateBack){
                            CurrentdayView().navigationBarBackButtonHidden(true)
                        }
                }
                ToolbarItem(placement:.navigationBarTrailing){
                    Button(
                        action: {
                            showCheckAlert = true
                        }) {
                        Image(systemName: "checkmark")
                    }
                }
            }
            // Set the tint here so the alert's default action adopts it
            .tint(.orange)
            .alert("Update learning goal", isPresented: $showCheckAlert) {
                Button("Dismiss", role: .cancel) { }
                Button("Update") {
                    // Keep your existing update logic
                    viewModel.commitGoalUpdateAndResetProgress()

                    // Ensure progress resets with the new array-backed storage used by CurrentdayView
                    let defaults = UserDefaults.standard

                    // Clear learned and freeze histories (JSON Data for [String])
                    defaults.set(Data(), forKey: "learnDatesData")
                    defaults.set(Data(), forKey: "freezeDatesData")

                    // Clear legacy single-date keys (optional but keeps things consistent)
                    defaults.set("", forKey: "lastLearnDate")
                    defaults.set("", forKey: "lastFreezeDate")

                    // Reset counters so UI reflects immediately even without navigating
                    defaults.set(0, forKey: "daysLearnedCount")
                    defaults.set(0, forKey: "freezesUsedCount")

                    // If you also change the allowed number of freezes in your view model,
                    // there's no need to touch the "freezes" key here. Otherwise, leave as-is.

                    navigateNext = true
                }
            } message: {
                Text("If you update now, your streak will start over.")
            }
        }
    }
}

#Preview {
    LearningGoalView().preferredColorScheme(.dark)
}
