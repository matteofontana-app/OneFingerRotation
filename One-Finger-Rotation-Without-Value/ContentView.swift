//
//  ContentView.swift
//  One-Finger-Rotation-Framework
//
//  Created by Matteo Fontana on 22/04/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        //Versions here
        
        ///Static movement powered views
        //RotatableElement()
        //Knob()
        //ValueRotation()
        //AutoRotation()
        
        /// Inertia powered views
        //FidgetSpinnerView()
        //KnobInertia()
        //ValueRotationInertia()
        VStack {
            Image("FidgetSpinner")
                .resizable()
                .frame(width: 200, height: 200)
                .modifier(SimpleRotation(rotationAngle: .degrees(20)))
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
