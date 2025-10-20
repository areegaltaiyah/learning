import SwiftUI

struct LearningGoalView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            VStack {
                Spacer().frame(height: 32)
                UserGoal().padding(.horizontal)
                Spacer()
                
            }
            .navigationTitle("Learning Goal")
            .bold()
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(
                        // WARNING THE ACTION IS TEMPERORARY
                        action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement:.navigationBarTrailing){
                    Button(
                        // WARNING THE ACTION IS TEMPERORARY
                        action: {
                        presentationMode.wrappedValue.dismiss()
                        })
                    {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)

                        
                        }
                }
            }
        }
    }
}


#Preview {
    LearningGoalView()
}
