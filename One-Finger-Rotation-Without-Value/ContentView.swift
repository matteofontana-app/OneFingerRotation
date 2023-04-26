//
//  ContentView.swift
//  One-Finger-Rotation
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
            Spacer()
            Rectangle()
                .foregroundColor(.red)
                .frame(width: 300, height: 300)
                .modifier(FidgetSpinner(friction: 0.995, velocityMultiplier: 0.1))
            Spacer()
            Image("FidgetSpinner")
                .resizable()
                .frame(width: 300, height: 300)
                .modifier(FidgetSpinner(friction: 0.995, velocityMultiplier: 0.1))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
