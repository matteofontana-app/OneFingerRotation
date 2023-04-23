//
//  RotatableElementInertia.swift
//  One-Finger-Rotation
//
//  Created by Matteo Fontana on 23/04/23.
//

import SwiftUI

struct RotatableElementInertia: View {
    @State private var rotationAngle: Angle = .zero
    @GestureState private var gestureRotation: Angle = .zero
    @State private var angularVelocity: Double = 0.0
    @State private var lastUpdateTime: Date? = nil
    
    private let friction: Double = 0.99
    private let timerInterval: TimeInterval = 1/60
    
    var body: some View {
        Rectangle()
            .fill(Color.red)
            .frame(width: 200, height: 200)
            .rotationEffect(rotationAngle + gestureRotation)
            .gesture(
                DragGesture()
                    .updating($gestureRotation) { value, state, _ in
                        state = calculateRotationAngle(from: value)
                        lastUpdateTime = Date()
                    }
                    .onEnded { value in
                        guard let lastUpdateTime = lastUpdateTime else { return }
                        
                        let previousAngle = calculateRotationAngle(from: value)
                        let currentTime = Date()
                        let timeDelta = currentTime.timeIntervalSince(lastUpdateTime)
                        
                        angularVelocity = previousAngle.radians - gestureRotation.radians
                        angularVelocity /= timeDelta
                        
                        rotationAngle = rotationAngle + gestureRotation
                        
                        if abs(angularVelocity) > 0.001 {
                            applyInertia()
                        }
                    }
                
            )
    }
    
    private func calculateRotationAngle(from value: DragGesture.Value) -> Angle {
        let centerX = value.startLocation.x - 100
        let centerY = value.startLocation.y - 100
        
        let startVector = CGVector(dx: centerX, dy: centerY)
        
        let endX = value.startLocation.x + value.translation.width - 100
        let endY = value.startLocation.y + value.translation.height - 100
        let endVector = CGVector(dx: endX, dy: endY)
        
        let angleDifference = atan2(startVector.dy * endVector.dx - startVector.dx * endVector.dy, startVector.dx * endVector.dx + startVector.dy * endVector.dy)
        return Angle(radians: -Double(angleDifference))
    }
    
    private func applyInertia() {
        Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { timer in
            withAnimation(.linear(duration: timerInterval)) {
                rotationAngle = rotationAngle + Angle(radians: angularVelocity * timerInterval)
            }
            
            angularVelocity *= friction
            
            if abs(angularVelocity) < 0.001 {
                angularVelocity = 0
                timer.invalidate()
            }
        }
    }
}

struct RotatableElementInertia_Previews: PreviewProvider {
    static var previews: some View {
        RotatableElementInertia()
    }
}
