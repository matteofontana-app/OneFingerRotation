//
//  ValueRotation.swift
//  One-Finger-Rotation
//
//  Created by Matteo Fontana on 23/04/23.
//

import SwiftUI

struct ValueRotation: ViewModifier {
    @State private var rotationAngle: Angle = .degrees(0)
    @State private var previousAngle: Double = 0
    @State private var fullRotations: Int = 0
    var onAngleChanged: (Double) -> Void

    init(initialTotalAngle: Double, onAngleChanged: @escaping (Double) -> Void) {
        rotationAngle = Angle(degrees: initialTotalAngle)
        self.onAngleChanged = onAngleChanged
    }
    
    /// viewSize is needed for the calculation of the Width and Height of the View.
    @State private var viewSize: CGSize = .zero

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(key: FrameSizeKeyValueRotation.self, value: geometry.size)
                    }
                )
                .onPreferenceChange(FrameSizeKeyValueRotation.self) { newSize in
                    viewSize = newSize
                }
            /// The ".position" modifier fix the center of the content.
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .rotationEffect(rotationAngle, anchor: .center)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let dragAngle = angleForDrag(value: value, geometry: geometry)
                            let angleDifference = dragAngle.degrees - previousAngle

                            if angleDifference > 180 {
                                fullRotations -= 1
                            } else if angleDifference < -180 {
                                fullRotations += 1
                            }

                            let currentAngle = rotationAngle.degrees + angleDifference
                            rotationAngle = Angle(degrees: currentAngle)
                            previousAngle = dragAngle.degrees

                            onAngleChanged(currentAngle + Double(fullRotations) * 360)
                        }
                        .onEnded { _ in
                            previousAngle = 0
                        }
                )
        }
        /// This ".frame" modifier ensures that the content is at the center of the view always.
        .frame(width: viewSize.width, height: viewSize.height)
    }
    
    private func angleForDrag(value: DragGesture.Value, geometry: GeometryProxy) -> Angle {
        let centerX = value.startLocation.x - geometry.size.width / 2
        let centerY = value.startLocation.y - geometry.size.height / 2
        
        let startVector = CGVector(dx: centerX, dy: centerY)
        
        let endX = value.startLocation.x + value.translation.width - geometry.size.width / 2
        let endY = value.startLocation.y + value.translation.height - geometry.size.height / 2
        let endVector = CGVector(dx: endX, dy: endY)
        
        let angleDifference = atan2(startVector.dy * endVector.dx - startVector.dx * endVector.dy, startVector.dx * endVector.dx + startVector.dy * endVector.dy)
        return Angle(radians: -Double(angleDifference))
    }
    
}

extension View {
    func valueRotation(initialTotalAngle: Double, onAngleChanged: @escaping (Double) -> Void) -> some View {
        self.modifier(ValueRotation(initialTotalAngle: initialTotalAngle, onAngleChanged: onAngleChanged))
    }
}

/// This PreferenceKey is necessary for the calculation of the frame width and height of the content.
struct FrameSizeKeyValueRotation: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
