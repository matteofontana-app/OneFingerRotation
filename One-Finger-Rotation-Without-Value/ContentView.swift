//
//  ContentView.swift
//  One-Finger-Rotation
//  Created by Matteo Fontana on 22/04/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        //Versions here
        
        //RotatableElement()
        //Knob()
        //ValueRotation()
        //AutoRotation()
        
        //RotatableElementInertia()
        FidgetSpinnerView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
