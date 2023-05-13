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
    
    /// viewSize is needed for the calculation of the Width and Height of the View.
    @State private var viewSize: CGSize = .zero
    
    public init(rotationAngle: Angle = .degrees(0.0), angleSnap: Binding<Double?> = .constant(nil)) {
        _rotationAngle = State(initialValue: rotationAngle)
        _angleSnap = angleSnap
    }
    
    public func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(key: FrameSizeKeySimpleRotation.self, value: geometry.size)
                    }
                )
                .onPreferenceChange(FrameSizeKeySimpleRotation.self) { newSize in
                    viewSize = newSize
                }
            /// The ".position" modifier fix the center of the content.
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .rotationEffect(rotationAngle + gestureRotation, anchor: .center)
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
        /// This ".frame" modifier ensures that the content is at the center of the view always.
        .frame(width: viewSize.width, height: viewSize.height)
    }
    
    public func calculateRotation(value: DragGesture.Value) -> Angle {
        let centerX = viewSize.width / 2
        let centerY = viewSize.height / 2
        let startVector = CGVector(dx: value.startLocation.x - centerX, dy: value.startLocation.y - centerY)
        let endVector = CGVector(dx: value.location.x - centerX, dy: value.location.y - centerY)
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

struct FrameSizeKeySimpleRotation: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
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
