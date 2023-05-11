//
//  KnobRotation.swift
//  One-Finger-Rotation-Framework
//
//  Created by Matteo Fontana on 23/04/23.
//

import SwiftUI

public struct KnobInertia: ViewModifier {
    @State private var rotationAngle: Angle = .degrees(0)
    @Binding var knobValue: Double
    @GestureState private var gestureRotation: Angle = .zero
    @State private var lastVelocity: CGFloat = 0
    @State private var isSpinning = false
    @State private var timer: Timer?
    @Binding var friction: CGFloat
    @Binding var stoppingAnimation: Bool
    @Binding var velocityMultiplier: CGFloat
    @State private var viewSize: CGSize = .zero
    var animation: Animation?
    @State private var isDragged: Bool = false
    let rotationThreshold: CGFloat = 12.0
    var onKnobValueChanged: (Double) -> Void
    @State var totalAngle: Double
    @State private var previousAngle: Double = 0
    @State private var rotationDirection: Double = 1
    @State var minAngle: Double
    @State var maxAngle: Double
    /// Initialization of three declarable and optional values.
    public init(knobValue: Binding<Double>,
        minAngle: Double, maxAngle: Double,
        friction: Binding<CGFloat> = .constant(0.1),
        velocityMultiplier: Binding<CGFloat> = .constant(0.1),
        rotationAngle: Angle = .degrees(0.0),
        animation: Animation? = nil,
        onKnobValueChanged: @escaping (Double) -> Void,
        stoppingAnimation: Binding<Bool> = .constant(false)
    ){
        self._knobValue = knobValue
        self.minAngle = minAngle
        self.maxAngle = maxAngle
        self._friction = friction
        self._velocityMultiplier = velocityMultiplier
        self.rotationAngle = Angle(degrees: minAngle+(maxAngle-minAngle)*knobValue.wrappedValue)
        self.onKnobValueChanged = onKnobValueChanged
        self.animation = animation
        self.totalAngle = minAngle+(maxAngle-minAngle)*knobValue.wrappedValue
        self._stoppingAnimation = stoppingAnimation
    }
    
    public func body(content: Content) -> some View {
        GeometryReader { geometry in
            
            content
            
            /// The ".background" modifier and the ".onPreferenceChange" update the automatic frame calculation of the content.
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(key: FrameSizeKeyKnobInertia.self, value: geometry.size)
                    }
                )
                .onPreferenceChange(FrameSizeKeyKnobInertia.self) { newSize in
                    viewSize = newSize
                }
            /// The ".position" modifier fix the center of the content.
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            /// The ".rotationEffect" modifier is necessary for the gesture functions, it applies the specific rotation.
                .rotationEffect(rotationAngle + gestureRotation, anchor: .center)
            
                .onChange(of: knobValue) { newValue in
                    if !isDragged && isSpinning {
                        if let animation = animation {
                            withAnimation(animation) {
                                rotationAngle = Angle(degrees: minAngle+(maxAngle-minAngle)*newValue)
                                if stoppingAnimation {
                                    timer?.invalidate()
                                    isSpinning = false
                                }
                                stoppingAnimation = false
                            }
                        }
                        else {
                            rotationAngle = Angle(degrees: minAngle+(maxAngle-minAngle)*newValue)
                            if stoppingAnimation {
                                timer?.invalidate()
                                isSpinning = false
                            }
                            stoppingAnimation = false
                        }
                    }
                    if !isDragged && !isSpinning {
                        if let animation = animation {
                            withAnimation(animation) {
                                rotationAngle = Angle(degrees: minAngle+(maxAngle-minAngle)*newValue)
                            }
                        } else {
                            rotationAngle = Angle(degrees: minAngle+(maxAngle-minAngle)*newValue)
                        }
                    }
                }
            
                .onChange(of: stoppingAnimation) { newValue in
                    if !isSpinning && !isDragged {
                        stoppingAnimation = false
                    }
                }
            
            /// The ".gesture" modifier is necessary for the gesture functions.
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isDragged = true
                            timer?.invalidate()
                            let dragAngle = calculateRotationAngle(value: value, geometry: geometry)
                            var angleDifference = dragAngle.degrees - previousAngle
                            
                            // Handle angle difference when crossing the ±180 boundary
                            if abs(angleDifference) > 180 {
                                angleDifference = angleDifference > 0 ? angleDifference - 360 : angleDifference + 360
                            }
                            
                            // Determine rotation direction
                            rotationDirection = angleDifference >= 0 ? 1 : -1
                            
                            let currentAngle = rotationAngle.degrees + angleDifference
                            rotationAngle = Angle(degrees: currentAngle)
                            let clampedAngle = min(max(minAngle, currentAngle), maxAngle)
                            
                            if abs(angleDifference) < 90 { // Add this line to check the angleDifference threshold
                                if minAngle...maxAngle ~= clampedAngle {
                                    rotationAngle = Angle(degrees: clampedAngle)
                                    knobValue = (clampedAngle - minAngle) / (maxAngle - minAngle)
                                }
                            }
                            
                            previousAngle = dragAngle.degrees
                            
                            // Update totalAngle without adding fullRotations * 360
                            totalAngle += angleDifference
                            onKnobValueChanged(knobValue)
                        }
                        .onEnded { value in
                            previousAngle = 0
                            isDragged = false
                            isSpinning = true
                            rotationAngle += gestureRotation
                            let velocity = CGPoint(x: value.predictedEndLocation.x - value.location.x, y: value.predictedEndLocation.y - value.location.y)
                            lastVelocity = sqrt(pow(velocity.x, 2) + pow(velocity.y, 2)) * velocityMultiplier
                            onKnobValueChanged(knobValue)
                            
                            if abs(velocity.x) > rotationThreshold || abs(velocity.y) > rotationThreshold {
                                isSpinning = true
                                timer?.invalidate()
                                timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                                    let angle = Angle(degrees: Double(lastVelocity) * rotationDirection)
                                    let newRotationAngle = rotationAngle + angle
                                    let clampedAngle = min(max(minAngle, newRotationAngle.degrees), maxAngle)
                                    if abs(newRotationAngle.degrees - clampedAngle) > 0.1 {
                                        let deceleration = 0.2 * rotationDirection
                                        rotationAngle = Angle(degrees: clampedAngle + deceleration)
                                        knobValue = (rotationAngle.degrees - minAngle) / (maxAngle - minAngle) // Update knobValue here
                                        onKnobValueChanged(knobValue)
                                        lastVelocity *= (1 - friction)
                                        if lastVelocity < 0.1 {
                                            timer.invalidate()
                                            isSpinning = false
                                        }
                                    } else {
                                        rotationAngle = newRotationAngle
                                        knobValue = (rotationAngle.degrees - minAngle) / (maxAngle - minAngle) // Update knobValue here
                                        onKnobValueChanged(knobValue)
                                        lastVelocity *= (1 - friction)
                                        if lastVelocity < 0.1 || (newRotationAngle.degrees < minAngle || newRotationAngle.degrees > maxAngle) {
                                            timer.invalidate()
                                            isSpinning = false
                                        }
                                    }
                                }
                            } else {
                                timer?.invalidate()
                                isSpinning = false
                            }
                        }
                )
            
            
            /// The ".onAppear" modifier is necessary for the gesture functions.
                .onAppear {
                    timer?.invalidate()
                }
            
            /// The ".onDisappear" modifier is necessary for the gesture functions.
                .onDisappear {
                    timer?.invalidate()
                }
        }
        
        /// This ".frame" modifier ensures that the content is at the center of the view always.
        .frame(width: viewSize.width, height: viewSize.height)
    }
    
    /// The function calculateRotationAngle calculates the angle according to the finger movement.
    public func calculateRotationAngle(value: DragGesture.Value, geometry: GeometryProxy) -> Angle {
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

/// This PreferenceKey is necessary for the calculation of the frame width and height of the content.
struct FrameSizeKeyKnobInertia: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

public extension View {
    func knobInertia(
        knobValue: Binding<Double>,
        minAngle: Double? = nil,
        maxAngle: Double? = nil,
        friction: Binding<CGFloat>? = nil,
        onKnobValueChanged: @escaping (Double) -> Void,
        velocityMultiplier: Binding<CGFloat>? = nil,
        animation: Animation? = nil,
        stoppingAnimation: Binding<Bool>? = nil) -> some View
    {
        let effect = KnobInertia(
            knobValue: knobValue,
            minAngle: minAngle ?? -90,
            maxAngle: maxAngle ?? 90,
            friction: friction ?? .constant(0.1),
            velocityMultiplier: velocityMultiplier ?? .constant(0.1),
            animation: animation,
            onKnobValueChanged: onKnobValueChanged,
            stoppingAnimation: stoppingAnimation ?? .constant(false)
        )
        return self.modifier(effect)
    }
}

