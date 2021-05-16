//
//  ContentView.swift
//  Project_4_BetterRest
//
//  Created by Thomas George on 15/05/2021.
//

import SwiftUI

struct ContentView: View {
    @State private var sleepAmount: Double = 8.0
    @State private var wakeUp: Date = defaultWakeTime
    @State private var coffee: Int = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var alertShowing = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    var body: some View {
        NavigationView {
            Form {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Choose your wake-up")
                        .font(.headline)
                    DatePicker("", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(WheelDatePickerStyle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                        Text("\(self.sleepAmount, specifier: "%g") Hours")
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily coffee intake")
                        .font(.headline)
                    Stepper(value: $coffee, in: 1...10) {
                        if self.coffee == 1 {
                            Text("1 cup")
                        } else {
                            Text("\(self.coffee) cups")
                        }
                    }
                }
            }
            .navigationBarTitle("BetterRest")
            .navigationBarItems(trailing:
                Button(action: calculateBedtime) {
                    Text("Calculate")
                }
            )
            .alert(isPresented: $alertShowing){
                Alert(title: Text("\(self.alertTitle)"), message: Text("\(self.alertMessage)"), dismissButton: .default(Text("Good Night")))
            }
        }
    }
    
    func calculateBedtime() {
        let model = SleepCalculator()
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: self.wakeUp)
        
        // Get values in seconds
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: self.sleepAmount, coffee: Double(self.coffee))
            
            let sleepTime = self.wakeUp - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            self.alertTitle = "Your ideal bedtime is ..."
            self.alertMessage = formatter.string(from: sleepTime)
        } catch {
            self.alertTitle = "Error"
            self.alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        
        alertShowing = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
