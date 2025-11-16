import SwiftUI

struct LearningGoalView: View {
    @EnvironmentObject private var onboardingVM: OnboardingViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var navigateBack = false
    @State private var showCheckAlert = false

    var body: some View {
        NavigationStack {
            VStack {
                Spacer().frame(height: 32)
                UserGoal(viewModel: onboardingVM)
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
                            // Dismiss back to CurrentdayView
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
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
                    // Single-source reset
                    onboardingVM.resetAll()

                    // Pop back to CurrentdayView so it reappears and recomputes UI
                    dismiss()
                }
            } message: {
                Text("If you update now, your streak will start over.")
            }
        }
    }
}

#Preview {
    LearningGoalView()
        .preferredColorScheme(.dark)
        .environmentObject(OnboardingViewModel())
}
