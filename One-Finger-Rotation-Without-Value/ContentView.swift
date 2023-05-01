//
//  ContentView.swift
//  One-Finger-Rotation-Framework
//
//  Created by Matteo Fontana on 22/04/23.
//

import SwiftUI

struct ContentView: View {
    @State private var totalAngle1: Double = 0
    @State private var totalAngle2: Double = 0
    
    @State private var totalAngle3: Double = 0
    @State private var totalAngle4: Double = 0
    @State private var knobValue: Double = 0.5
    @State private var knobValue2: Double = 0.5
    @State var sliderValue: CGFloat = 0.995
    @State var valueChange: Bool = false
    
    //@State private var autoRotationSpeed: Double = 100
        @State private var autoRotationActive: Bool = false
    
    @State private var autoRotationSpeed: Double = 100 // Adjust the speed as needed
    @State private var autoRotationEnabled: Bool = true
    
    var body: some View {
        //Versions here
        VStack {
            
            
            
            ///Value Rotation Inertia
//            ZStack{
//                Image("FidgetSpinner")
//                    .resizable()
//                    .frame(width: 300, height: 300)
//                VStack{
//                    Rectangle()
//                        .foregroundColor(.red)
//                        .frame(width: 20, height: 20)
//                    Spacer()
//                }
//            }
//            .frame(width: 300, height: 300)
//            // Your spinner view using a fixed value for friction
//            .fidgetSpinnerValueEffect(totalAngle: $totalAngle3, friction: $sliderValue, onAngleChanged: { newAngle in
//                totalAngle3 = newAngle
//            }, velocityMultiplier: .constant(0.1), animation: .spring(), stoppingAnimation: $valueChange)
            // Your spinner view using the binding for friction
//            .fidgetSpinnerValueEffect(totalAngle: $totalAngle3, friction: $sliderValue, onAngleChanged: { newAngle in
//                totalAngle3 = newAngle
//            }, velocityMultiplier: .constant(0.1), animation: .spring())
//            Text("Total Angle: \(totalAngle3, specifier: "%.2f")")
//            Button(action: {
//                totalAngle3 = 40
//                valueChange = true
//            }, label: {
//                Text("Test")
//            })
//            Slider(value: $sliderValue, in: 0...1)
//            Text("Slider value: \(sliderValue, specifier: "%.4f")")
            
            
            
            /// Value Rotation
//            Image("FidgetSpinner")
//                .resizable()
//                .frame(width: 200, height: 200)
//                .valueRotation(totalAngle: $totalAngle2, onAngleChanged: { newAngle in
//                    totalAngle2 = newAngle
//                })
//            Text("Total Angle: \(totalAngle2, specifier: "%.2f")")
//            Button(action: {
//                totalAngle2 = 0
//            }, label: {
//                Text("Test")
//            })
            /// Insert animation after comma
//            Image("FidgetSpinner")
//                .resizable()
//                .frame(width: 300, height: 300)
//                .valueRotation(totalAngle: $totalAngle1, onAngleChanged: { newAngle in
//                    totalAngle1 = newAngle
//                }, animation: .easeInOut(duration:0.5))
//            Text("Total Angle: \(totalAngle1, specifier: "%.2f")")
//            Button(action: {
//                totalAngle1 = 0
//            }, label: {
//                Text("Test")
//            })
            
            
            /// Knob Rotation
            ZStack{
                Circle()
                    .foregroundColor(.green)
                VStack{
                    Rectangle()
                        .frame(width: 20, height: 80)
                    Spacer()
                }
            }
                .frame(width: 300, height: 300)
                .foregroundColor(.red)
                .knobInertia(knobValue: $knobValue2, minAngle: -180, maxAngle: 180, friction: .constant(0.8), onKnobValueChanged: { newValue in
                    knobValue2 = newValue
                }, velocityMultiplier: .constant(0.1), animation: .spring(), stoppingAnimation: $valueChange)
            Text("Total Angle: \(knobValue2, specifier: "%.2f")")
            Button(action: {
                knobValue2 = 0.6
                valueChange = true
            }, label: {
                Text("Test")
            })
            
            
            
            
            /// Knob Rotation
//            ZStack{
//                Circle()
//                    .foregroundColor(.green)
//                VStack{
//                    Rectangle()
//                        .frame(width: 20, height: 80)
//                    Spacer()
//                }
//            }
//                .frame(width: 200, height: 200)
//                .foregroundColor(.red)
//                .knobRotation(knobValue: $knobValue, minAngle: -180, maxAngle: 180, onKnobValueChanged: { newValue in
//                    knobValue = newValue
//                }, animation: .spring())
//            Text("Total Angle: \(knobValue, specifier: "%.2f")")
//            Button(action: {
//                knobValue = 0.6
//            }, label: {
//                Text("Test")
//            })
            
            
            
            /// Fidget Spinner Effect
//            Image("FidgetSpinner")
//                .resizable()
//                .frame(width: 200, height: 200)
//                .fidgetSpinnerEffect(friction: $sliderValue, velocityMultiplier: .constant(0.6), rotationAngle: .degrees(80.0))
            /// Stock friction 0.995; velocityMultiplier: 0.1; rotationAngle .degrees(0)
//            Spacer()
//            Image("FidgetSpinner")
//                .resizable()
//                .frame(width: 200, height: 200)
//                .fidgetSpinnerEffect()
            
            
            ///Auto Value Rotation
//            Spacer()
//            Rectangle()
//                .frame(width: 200, height: 200)
//                .valueAutoRotation(
//                        totalAngle: $totalAngle4,
//                        onAngleChanged: { newAngle in
//                            totalAngle4 = newAngle
//                        }, animation: .spring(),
//                        autoRotationSpeed: $autoRotationSpeed,
//                        autoRotationEnabled: $autoRotationEnabled
//                    )
//            Spacer()
//            Button(action: {
//                autoRotationEnabled.toggle()
//            }, label: {
//                Text("Test")
//            })
//            Spacer()
//            Text("Total Angle: \(totalAngle4, specifier: "%.2f")")
//            Spacer()
//            Button(action: {
//                autoRotationSpeed = -1*autoRotationSpeed
//            }, label: {
//                Text("change")
//            })
//            Spacer()
//            Button(action: {
//                totalAngle4 = 0
//            }, label: {
//                Text("reset")
//            })
            
            
            
            ///Auto Rotation
//            Spacer()
//            Rectangle()
//                .frame(width: 200, height: 200)
//                .autoRotation(rotationAngle: .degrees(20), autoRotationSpeed: $autoRotationSpeed, autoRotationActive: $autoRotationActive)
//            Spacer()
//            Button(action: {
//                autoRotationActive.toggle()
//            }, label: {
//                Text("Test")
//            })
//            Spacer()
//            Button(action: {
//                autoRotationSpeed = -1*autoRotationSpeed
//            }, label: {
//                Text("change")
//            })
            /// Stock values are 0.0, 20.0, true
//            Rectangle()
//                .frame(width: 200, height: 200)
//                .autoRotation()
            
            
            
            
            /// Simple Rotation
//            Image("FidgetSpinner")
//                .resizable()
//                .frame(width: 200, height: 200)
//                .simpleRotation(rotationAngle: .degrees(20))
//                /// Stock rotationAngle .degrees(0)
//            Spacer()
//            Image("FidgetSpinner")
//                .resizable()
//                .frame(width: 200, height: 200)
//                .simpleRotation()
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
