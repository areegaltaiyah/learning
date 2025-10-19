//
//  CurrentdayView.swift
//  Learning
//
//  Created by Areeg Altaiyah on 26/04/1447 AH.
//
import SwiftUI

struct CurrentdayView: View {
    var body: some View {
        VStack{
            HStack(spacing:10){
                //---Navigation Bar---
                Text("Activity").bold().font(Font.largeTitle)
                Spacer()
                Image(systemName: "calendar")
                    .font(Font.system(size: 20))
                    .frame(width:44 ,height: 44)
                    .glassEffect()
                    
                
                Image(systemName: "pencil.and.outline")
                    .font(Font.system(size: 20))
                    .frame(width:44 ,height: 44)
                    .glassEffect()

            }.padding()
            
            //Calendar
            GlassEffectContainer {
                VStack (alignment:.leading) {
                    CalendarView()
                
                    Divider()
                    
                    Text("Learning Swift")
                        .bold()
                        .padding()
                        
                    HStack{
                        //Days learned
                        Spacer()
                        HStack{
                            Image(systemName: "flame.fill").foregroundStyle(Color.orange).font(Font.system(size: 24)).padding()
                            
                            
                            VStack(alignment:.leading){
                                Text("3").bold().font(.system(size: 24))
                                Text("Days Learned").font(.system(size: 13)).padding(.trailing)

                            }
                        }
                        .padding(10)
                        .glassEffect(.clear.tint(Color.orange.opacity(0.2)))
                        Spacer()

                        
                        //Days freezed
                        HStack{
                            Image(systemName: "cube.fill").foregroundStyle(Color.turqoisey).font(Font.system(size: 24)).padding()
                            VStack(alignment:.leading){
                                Text("1").bold().font(.system(size: 24))
                                Text("Days Freezed").font(.system(size: 13)).padding(.trailing)

                            }
                        }
                        .padding(10)
                        .glassEffect(.regular.tint(Color.turqoisey.opacity(0.2)))
                        Spacer()
                    }.padding(.bottom,10)
                }
            }.glassEffect(.clear,in:.rect(cornerRadius: 10))
            
            //BUTTON LOG AS LEARNED
            Button("Log as Learned") {
                /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
            }
            .bold()
            .foregroundStyle(Color.white)
            .font(.system(size: 38))
            .padding(100)
            .background(
                Circle()
                    .fill(Color.orangey.opacity(0.7))
                    .glassEffect(.clear.interactive())

            )
            .padding()
            // BUTTON LOG AS FREEZED
            Button("Log as Freezed") {
                /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
            }
            .foregroundStyle(Color.white)
            .font(.system(size: 17))
                        
        }
    }
}


//Calendar Struct
struct CalendarView: View {
    @State private var date = Date()
    
    var body: some View {
        
        VStack() {
            
            HStack {
                //Top part month and year
                Text("October 2025").bold()
                Image(systemName: "chevron.right").foregroundStyle(Color.orange).bold()
                
                Spacer()
                Image(systemName: "chevron.left").foregroundStyle(Color.orange).bold()
                    .padding(.trailing,20)
                Image(systemName: "chevron.right").foregroundStyle(Color.orange).bold()
                
                
            }.padding()
            let days = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
            let dates = ["20", "21", "22", "23", "24", "25", "26"]
            
            HStack(spacing: 12) {
                ForEach(0..<days.count, id: \.self) { index in
                    VStack {
                        Text(days[index])
                            .foregroundStyle(Color.greyish)
                            .bold()
                            .font(.subheadline)
                        
                        Text(dates[index])
                            .bold()
                            .padding(10)
                            .background(
                                Circle().fill(Color.darkTurqoise)
                            )
                    }
                }
            }
            .padding(.bottom, 5)
            
            
        }
    }
    
}

//Days Learned Struct
//struct DaysLearned{
//    
//}
//Days Freezed Struct

#Preview {
    CurrentdayView().preferredColorScheme(.dark)
}
