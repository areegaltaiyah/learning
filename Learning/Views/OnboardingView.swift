//
//  ContentView.swift
//  Learning
//
//  Created by Areeg Altaiyah on 24/04/1447 AH.
//
import SwiftUI

struct OnboardingView: View {
    var body: some View {
            
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
                    
                    
                    UserGoal()

                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                Spacer()
                
                // Start Learning button
                Button("Start learning") {
                }
                .fontWeight(.medium)
                .frame(width:182 ,height: 48)
                .foregroundStyle(Color.white)
                .glassEffect(.clear.tint(.orangey.opacity(0.8)).interactive())
                
            }
        }
    }

struct UserGoal : View{
 
    var body: some View {
        
        
        
        //---Textfield---
        VStack {
            VStack(alignment: .leading){
                Text("I want to learn")
                    .font(Font.system(size: 22))
                TextField("Swift", text: .constant(""))
            }
        
        Spacer().frame(height: 24)

        
        // Choose duration
        VStack(alignment: .leading){
            Text("I want to learn it in a")
                .font(Font.system(size: 22))
            
            Spacer().frame(height: 12)

            
            // Duration buttons group
            TimeFilterView().frame(maxWidth:.infinity,alignment: .leading)

            
            }
        }

    }
    
}
struct meow :View {
    var body: some View {
        HStack(spacing:8){
            Button("Week") { }
                .font(Font.system(size: 17))
                .fontWeight(.medium)
            
                .frame(width:97 ,height: 48)
                .foregroundStyle(Color.white)
                .glassEffect(.clear.interactive().tint(Color.orangey))
            
            Button("Month") { }
                .font(Font.system(size: 17))
                .fontWeight(.medium)
            
                .frame(width:97 ,height: 48)
                .foregroundStyle(Color.white)
                .glassEffect(.clear.interactive())
            
            Button("Year") { }
                .font(Font.system(size: 17))
                .fontWeight(.medium)
            
                .frame(width:97 ,height: 48)
                .foregroundStyle(Color.white)
                .glassEffect(.clear.interactive())
        }
    }
}
    
    
    
struct TimeFilterView: View {
    @State private var selected = "Week"

    var body: some View {
        HStack(spacing: 8) {
            button(title: "Week")
            button(title: "Month")
            button(title: "Year")
        }
    }

    private func button(title: String) -> some View {
        Button(action: {
            selected = title
        }) {
            Text(title)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 97, height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 40)
                        .fill(selected == title ? Color.orangey : Color.white.opacity(0.1))
                       
                        .glassEffect()
                )
        }
    }
}

#Preview {
    OnboardingView()
}
