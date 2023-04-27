//
//  ContentView.swift
//  One-Finger-Rotation-Framework
//
//  Created by Matteo Fontana on 22/04/23.
//

import SwiftUI

struct ContentView: View {
    @State private var totalAngle: Double = 20
    
    var body: some View {
        //Versions here
        VStack {
            Image("FidgetSpinner")
                .resizable()
                .frame(width: 200, height: 200)
                .valueRotation(initialTotalAngle: totalAngle, onAngleChanged: { newAngle in
                    totalAngle = newAngle
                })
            Text("Total Angle: \(totalAngle, specifier: "%.2f")")
            Spacer()
            Image("FidgetSpinner")
                .resizable()
                .frame(width: 200, height: 200)
                .modifier(FidgetSpinnerEffect(friction: 0.8, velocityMultiplier: 0.1, rotationAngle: .degrees(80.0)))
            Spacer()
            Image("FidgetSpinner")
                .resizable()
                .frame(width: 200, height: 200)
                .modifier(FidgetSpinnerEffect())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
