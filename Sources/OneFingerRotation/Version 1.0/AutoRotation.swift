//
//  AutoRotation.swift
//  One-Finger-Rotation-Without-Value
//
//  Created by Matteo Fontana on 30/04/23.
//

import SwiftUI

///Struct for Auto Rotation
public struct AutoRotation: ViewModifier {
    ///Variable for general rotationAngle, which calculates the initial angle of the content.
    @State private var rotationAngle: Angle = .zero
    ///Variable for the calculation of the gesture Angle
    @GestureState private var gestureRotation: Angle = .zero
    
    @Binding var autoRotationSpeed: Double
    @Binding var autoRotationActive: Bool
    @State private var viewSize: CGSize = .zero
    @Binding var angleSnap: Double?
    
    var timer: Timer {
            Timer.scheduledTimer(withTimeInterval: 1 / 60, repeats: true) { _ in
                if autoRotationActive && gestureRotation == .zero {
                    rotationAngle = rotationAngle + Angle(degrees: autoRotationSpeed / 60)
                    if let snap = angleSnap {
                        rotationAngle = Angle(degrees: nearestMultiple(of: snap, for: rotationAngle.degrees))
                    }
                }
            }
        }
    
    func nearestMultiple(of multiple: Double, for value: Double) -> Double {
            let quotient = (value / multiple).rounded()
            return quotient * multiple
        }
    
    public init(
          rotationAngle: Angle = .degrees(0.0),
          autoRotationSpeed: Binding<Double>,
          autoRotationActive: Binding<Bool>,
          angleSnap: Binding<Double?> = .constant(nil)
      ) {
          _rotationAngle = State(initialValue: rotationAngle)
          _autoRotationSpeed = autoRotationSpeed
          _autoRotationActive = autoRotationActive
          _angleSnap = angleSnap
      }
    
    public func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
            /// The ".background" modifier and the ".onPreferenceChange" update the automatic frame calculation of the content.
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(key: FrameSizeKeyAutoRotation.self, value: geometry.size)
                    }
                )
                .onPreferenceChange(FrameSizeKeyAutoRotation.self) { newSize in
                    viewSize = newSize
                }
            /// The ".position" modifier fix the center of the content.
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .rotationEffect(rotationAngle + gestureRotation, anchor: .center)
                .gesture(
                    DragGesture()
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
                                                if let snap = angleSnap {
                                                    rotationAngle = Angle(degrees: nearestMultiple(of: snap, for: rotationAngle.degrees))
                                                }
                        }
                )
                .onAppear {
                    _ = timer
                }
                .onDisappear {
                    timer.invalidate()
                }
        }
        .frame(width: viewSize.width, height: viewSize.height)
    }
}

struct FrameSizeKeyAutoRotation: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

public extension View {
    func autoRotation(
        rotationAngle: Angle? = nil,
        autoRotationSpeed: Binding<Double>? = nil,
        autoRotationActive: Binding<Bool>? = nil,
        angleSnap: Binding<Double?>? = nil) -> some View
    {
        let effect = AutoRotation(
            rotationAngle: rotationAngle ?? .degrees(0.0),
            autoRotationSpeed: autoRotationSpeed ?? .constant(20.0),
            autoRotationActive: autoRotationActive ?? .constant(true),
            angleSnap: angleSnap ?? .constant(nil)
        )
        return self.modifier(effect)
    }
}
