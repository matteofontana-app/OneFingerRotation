//
//  SimpleRotation.swift
//  One-Finger-Rotation-Framework
//
//  Created by Matteo Fontana on 23/04/23.
//

import SwiftUI

struct SimpleRotation: ViewModifier {
    @State private var rotationAngle: Angle = .zero
    @GestureState private var gestureRotation: Angle = .zero
    
    init(rotationAngle: Angle = .degrees(0.0)) {
            _rotationAngle = State(initialValue: rotationAngle)
    }
    
    func body(content: Content) -> some View {
        content
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
