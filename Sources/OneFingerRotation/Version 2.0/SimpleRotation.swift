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
        /// This ".frame" modifier ensures that the content is at the center of the view always.
        .frame(width: viewSize.width, height: viewSize.height)
    }
    
    public func calculateRotation(value: DragGesture.Value) -> Angle {
        let centerX = value.startLocation.x - 100
        let centerY = value.startLocation.y - 100
        let startVector = CGVector(dx: centerX, dy: centerY)
        let endX = value.startLocation.x + value.translation.width - 100
        let endY = value.startLocation.y + value.translation.height - 100
        let endVector = CGVector(dx: endX, dy: endY)
        let angleDifference = atan2(startVector.dy * endVector.dx - startVector.dx * endVector.dy, startVector.dx * endVector.dx + startVector.dy * endVector.dy)
        var rotation = Angle(radians: -Double(angleDifference))
        
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
