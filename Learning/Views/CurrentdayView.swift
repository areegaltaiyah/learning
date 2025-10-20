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
           CurrentNavigation()
            Spacer().frame(height: 24)
            //Card
            CurrentCard()
            
            Spacer().frame(height: 32)

            //BUTTON LOG AS LEARNED
            Learnedbutton()
            
            Spacer().frame(height: 32)

            // BUTTON LOG AS FREEZED
            Freezedbutton()
            Text("1 out of 2 Freezes used")
                .font(Font.system(size: 14))
                .foregroundStyle(Color.secondary)

        }
    }
}
//-------------------------Structs---------------------
//Card Struct
struct CurrentCard: View {
    var body: some View {
        GlassEffectContainer {
            HStack {
                Spacer().frame(width: 12)
                VStack (alignment:.leading) {
                    CalendarView()
                    Spacer().frame(height: 12)
                    Divider()
                    Spacer().frame(height: 11.5)
                    Text("Learning Swift")
                        .bold()
                    Spacer().frame(height: 12)

                    HStack{
                        //Days learned
                        DaysLearned()
                        
                        Spacer()

                        //Days freezed
                        
                        DaysFreezed()
                        
                    }
                    Spacer().frame(height: 12)

                }
                Spacer().frame(width: 12)
            }
            
        }
        
        .glassEffect(.clear,in:.rect(cornerRadius: 10))
    }
}

//Navigation bar
struct CurrentNavigation: View {
    var body: some View {
        HStack(spacing:10){
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

        }
    }
}

//Calendar Struct
struct CalendarView: View {
    @State private var date = Date()
    
    var body: some View {
        
        VStack() {
            Spacer().frame(height: 13)
            HStack {
                //Top part month and year
                Text("October 2025").bold()
                Image(systemName: "chevron.right").foregroundStyle(Color.orange).bold()
                
                Spacer()
                Image(systemName: "chevron.left").foregroundStyle(Color.orange).bold()
                Spacer().frame(width: 28)
                Image(systemName: "chevron.right").foregroundStyle(Color.orange).bold()
                
                
            }
            Spacer().frame(height: 15)
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
                            .foregroundStyle(Color.turqoisey)
                            .bold()
                            .padding(7)
                            .background(
                                Circle().fill(Color.darkTurqoise)
                            )
                            .font(.system(size: 24))
                            
                    }
                }
            }
            
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
        }.frame(width: 180 ,height:79)
        
        .glassEffect(.clear.tint(Color.orange.opacity(0.2)))
    }
}

//Days Freezed Struct
struct DaysFreezed: View{
    var body: some View{
        HStack{
            Spacer().frame(width: 14)
            Image(systemName: "cube.fill").foregroundStyle(Color.turqoisey).font(Font.system(size: 20))
            
            VStack(alignment:.leading){
                Text("1").bold().font(.system(size: 24))
                Text("Days Freezed").font(.system(size: 12))
                Spacer().frame(height: 6)

            }.frame(width: 78,height: 49)
            Spacer().frame(width: 14)
        }
        .frame(width: 180 ,height:79)        .glassEffect(.regular.tint(Color.turqoisey.opacity(0.2)))
    }
}

//Log as Learned button
struct Learnedbutton : View{
    var body: some View{
        Button("Log as Learned") {
            /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
        }
        .bold()
        .foregroundStyle(Color.white)
        .font(.system(size: 38))
        .padding(100)
        .background(
            Circle()
                .fill(Color.orangey.opacity(0.95))
                .glassEffect(.clear.interactive())

        )
    }
}

//Log as freezed
struct Freezedbutton : View{
    var body: some View{
        Button("Log as Freezed") {
            /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
        }
        .foregroundStyle(Color.white)
        .font(.system(size: 17))
        .frame(width: 274,height:48)
        .glassEffect(.regular.tint(Color.turqoisey.opacity(0.65)).interactive())
              
    }
}

#Preview {
    CurrentdayView().preferredColorScheme(.dark)
}
