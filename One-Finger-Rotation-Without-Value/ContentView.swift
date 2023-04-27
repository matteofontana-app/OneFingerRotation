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
    
    var body: some View {
        //Versions here
        VStack {
            
            
            
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
//                .frame(width: 200, height: 200)
//                .valueRotation(totalAngle: $totalAngle1, onAngleChanged: { newAngle in
//                    totalAngle1 = newAngle
//                }, animation: .easeInOut(duration:0.5))
//            Text("Total Angle: \(totalAngle1, specifier: "%.2f")")
//            Button(action: {
//                totalAngle1 = 0
//            }, label: {
//                Text("Test")
//            })
            
            
            
            /// Fidget Spinner Effect
//            Image("FidgetSpinner")
//                .resizable()
//                .frame(width: 200, height: 200)
//                .fidgetSpinnerEffect(friction: 0.8, velocityMultiplier: 0.1, rotationAngle: .degrees(80.0))
            /// Stock friction 0.995; velocityMultiplier: 0.1; rotationAngle .degrees(0)
//            Spacer()
//            Image("FidgetSpinner")
//                .resizable()
//                .frame(width: 200, height: 200)
//                .fidgetSpinnerEffect()

            
            
            /// Simple Rotation
//            Image("FidgetSpinner")
//                .resizable()
//                .frame(width: 200, height: 200)
//                .simpleRotation(rotationAngle: .degrees(20))
//                /// Stock rotationAngle .degrees(0)
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
