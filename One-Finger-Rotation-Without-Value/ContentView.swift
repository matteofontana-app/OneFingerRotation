//
//  ContentView.swift
//  One-Finger-Rotation-Without-Value
//
//  Created by Matteo Fontana on 22/04/23.
//

import SwiftUI

//This is the Rotable Element
struct RotatableElement: View {
    
    //Rotation Gesture variables: Angle of rotation at the end of gesture and real time value
    @State private var rotationAngle: Angle = .zero
    @GestureState private var gestureRotation: Angle = .zero

    var body: some View {
        
        //Replace this with the view you want to rotate
        Rectangle()
            .fill(Color.red)
            .frame(width: 200, height: 200)
        
            //Apply this modifier to apply the rotation effect
            .rotationEffect(rotationAngle + gestureRotation)
        
            //Apply this modifier to receive the input of rotation
            .gesture(
                DragGesture()
                    //Drag gesture of rotation while updating
                    .updating($gestureRotation) { value, state, _ in
                        let centerX = value.startLocation.x - 100
                        let centerY = value.startLocation.y - 100
                        
                        let startVector = CGVector(dx: centerX, dy: centerY)
                        
                        let endX = value.startLocation.x + value.translation.width - 100
                        let endY = value.startLocation.y + value.translation.height - 100
                        let endVector = CGVector(dx: endX, dy: endY)
                        
                        let angleDifference = atan2(startVector.dy * endVector.dx - startVector.dx * endVector.dy, startVector.dx * endVector.dx + startVector.dy * endVector.dy)
                        state = Angle(radians: -Double(angleDifference))
                    }
                    //Drag gesture of rotation when ended
                    .onEnded { value in
                        let centerX = value.startLocation.x - 100
                        let centerY = value.startLocation.y - 100
                        
                        let startVector = CGVector(dx: centerX, dy: centerY)
                        
                        let endX = value.startLocation.x + value.translation.width - 100
                        let endY = value.startLocation.y + value.translation.height - 100
                        let endVector = CGVector(dx: endX, dy: endY)
                        
                        let angleDifference = atan2(startVector.dy * endVector.dx - startVector.dx * endVector.dy, startVector.dx * endVector.dx + startVector.dy * endVector.dy)
                        rotationAngle = rotationAngle + Angle(radians: -Double(angleDifference))
                    }
            )
    }
}

struct ContentView: View {
    var body: some View {
        
        //Rotated element
        RotatableElement()
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
