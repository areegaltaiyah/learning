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
                // ---The fire circle---
                ZStack{
                    
                    Image(systemName: "flame.fill").foregroundStyle(Color.orange)
                        .font(Font.system(size: 36))
                        .frame(width:109 ,height: 109)
                        .glassEffect(.clear.tint(.orangey.opacity(0.05)))
                }
                
                
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
                    
                    
                    //---Textfield---
                    VStack(alignment: .leading){
                        Text("I want to learn")
                        TextField("Swift", text: .constant(""))
                    }
                    
                    Spacer().frame(height: 47)

                    
                    // Choose duration
                    VStack(alignment: .leading){
                        Text("I want to learn it in a")
                        // Duration buttons group
                        HStack{
                            Button("Week") { }
                                .frame(width:97 ,height: 48)
                                .foregroundStyle(Color.white)
                                .glassEffect(.clear.interactive())
                            
                            Button("Month") { }
                                .frame(width:97 ,height: 48)
                                .foregroundStyle(Color.white)
                                .glassEffect(.clear.interactive())
                            
                            Button("Year") { }
                                .frame(width:97 ,height: 48)
                                .foregroundStyle(Color.white)
                                .glassEffect(.clear.interactive())
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                Spacer()
                
                // Start Learning button
                Button("Start learning") {
                }
                .frame(width:182 ,height: 48)
                .foregroundStyle(Color.white)
                .glassEffect(.clear.tint(.orangey.opacity(0.8)).interactive())
                
            }
        }
    }


#Preview {
    OnboardingView()
}
