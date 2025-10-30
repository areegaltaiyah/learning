//
//  ContentView.swift
//  Learning
//
//  Created by Areeg Altaiyah on 24/04/1447 AH.
//
import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var onboardingVM: OnboardingViewModel
    @State private var navigateNext = false

    var body: some View {
        NavigationStack {
            VStack {
                ZStack{
                    Image(systemName: "flame.fill").foregroundStyle(Color.orange)
                        .font(Font.system(size: 36))
                        .frame(width:109 ,height: 109)
                        .glassEffect(.clear.tint(.flameBG))
                }.padding(.top, 40)
                
                Spacer().frame(height: 47)
                
                // ---Left-aligned content---
                VStack(alignment: .leading){
                    //---Hello learner and more---
                    VStack(alignment: .leading){
                        Text("Hello Learner")
                            .bold()
                            .font(Font.system(size:34))
                        Text("This app will help you learn everyday!").foregroundStyle(Color.secondary)
                            .font(Font.system(size: 17))
                    }
                    
                    Spacer().frame(height: 31)
                    
                    UserGoal(viewModel: onboardingVM )
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                Spacer()
                
                // Start Learning button
                Button("Start learning") {
                    navigateNext = true
                }
                .fontWeight(.medium)
                .frame(width:182 ,height: 48)
                .foregroundStyle(Color.white)
                .glassEffect(.clear.tint(.orangey.opacity(0.8)).interactive())
            }
            .navigationDestination(isPresented: $navigateNext){
                CurrentdayView().navigationBarBackButtonHidden(true)
            }
        }
    }
}


//-----------STRUCT-------------
struct UserGoal : View{
    @ObservedObject var viewModel : OnboardingViewModel
    
    var body: some View {
        //---Textfield---
        VStack {
            VStack(alignment: .leading){
                Text("I want to learn")
                    .font(Font.system(size: 22))
                TextField("Swift", text: Binding(
                    get: { viewModel.topic },
                    set: { viewModel.updateTopic($0) }
                ))
            }
        
            Spacer().frame(height: 24)

            // Choose duration
            VStack(alignment: .leading){
                Text("I want to learn it in a")
                    .font(Font.system(size: 22))
                
                Spacer().frame(height: 12)

                
                TimeFilterView(viewModel: viewModel)
                    .frame(maxWidth:.infinity,alignment: .leading)
            }
        }
    }
}
    
struct TimeFilterView: View {
    @ObservedObject  var viewModel: OnboardingViewModel
    
    var body: some View {
        HStack(spacing: 8) {
            durationButton("Week", freezes: 2)
            durationButton("Month", freezes: 8)
            durationButton("Year", freezes: 96)
        }
    }
    
    private func durationButton(_ title: String, freezes: Int) -> some View {
        Button {
            viewModel.updateDuration(title)
        } label: {
            Text(title)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 97, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 40)
                        .fill(viewModel.selectedDuration == title ? Color.orangey : Color.white.opacity(0.1))
                        .glassEffect()
                )
        }
    }
}

#Preview {
    OnboardingView()
        .preferredColorScheme(.dark)
        .environmentObject(OnboardingViewModel())
}

