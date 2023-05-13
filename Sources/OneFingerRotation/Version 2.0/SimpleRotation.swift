//
//  SimpleRotation.swift
//  One-Finger-Rotation-Framework
//
//  Created by Matteo Fontana on 23/04/23.
//

import SwiftUI

public struct SimpleRotation: ViewModifier {
    @State private var rotationAngle: Angle = .zero
    @GestureState private var gestureRotation: Angle = .zero
    @Binding private var angleSnap: Double?
    
    public init(rotationAngle: Angle = .degrees(0.0), angleSnap: Binding<Double?> = .constant(nil)) {
        _rotationAngle = State(initialValue: rotationAngle)
        _angleSnap = angleSnap
    }
    
    public func body(content: Content) -> some View {
        content
            .rotationEffect(rotationAngle + gestureRotation)
            .gesture(
                DragGesture()
                    .updating($gestureRotation) { value, state, _ in
                        state = calculateRotation(value: value)
                    }
                    .onEnded { value in
                        rotationAngle = rotationAngle + calculateRotation(value: value)
                    }
            )
    }
    
    public func calculateRotation(value: DragGesture.Value) -> Angle {
        let startVector = CGVector(dx: value.startLocation.x - 180, dy: value.startLocation.y - 180)
        let endVector = CGVector(dx: value.location.x - 180, dy: value.location.y - 180)

        let angleDifference = atan2(endVector.dy, endVector.dx) - atan2(startVector.dy, startVector.dx)
        var rotation = Angle(radians: Double(angleDifference))
        
        // Apply angle snapping if specified
        if let snap = angleSnap {
            let snapAngle = Angle(degrees: snap)
            let snappedRotation = round(rotation.radians / snapAngle.radians) * snapAngle.radians
            rotation = Angle(radians: snappedRotation)
        }
        
        return rotation
    }
}

public extension View {
    func simpleRotation(
        rotationAngle: Angle? = nil,
        angleSnap: Binding<Double?> = .constant(nil)) -> some View {
        let effect = SimpleRotation(
            rotationAngle: rotationAngle ?? .degrees(0.0),
            angleSnap: angleSnap
        )
        return self.modifier(effect)
    }
}
