//
//  FidgetSpinnerModifier.swift
//  One-Finger-Rotation-Framework
//
//  Created by Matteo Fontana on 23/04/23.
//

import SwiftUI

public struct ValueAutoRotationInertia: ViewModifier {
    @State private var rotationAngle: Angle = .degrees(0)
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
    var onAngleChanged: (Double) -> Void
    @Binding var totalAngle: Double
    @State private var previousAngle: Double = 0
    @State private var rotationDirection: Double = 1
    @Binding var autoRotationSpeed: Double
    @Binding var autoRotationEnabled: Bool
    @State private var autoRotationTimer: Timer? = nil
    /// Initialization of three declarable and optional values.
    public init(
        totalAngle: Binding<Double>,
        friction: Binding<CGFloat> = .constant(0.1),
        velocityMultiplier: Binding<CGFloat> = .constant(0.1),
        rotationAngle: Angle = .degrees(0.0),
        animation: Animation? = nil,
        onAngleChanged: @escaping (Double) -> Void,
        stoppingAnimation: Binding<Bool> = .constant(false),
        autoRotationSpeed: Binding<Double>,
        autoRotationEnabled: Binding<Bool>
    ){
        self._totalAngle = totalAngle
        self._friction = friction
        self._velocityMultiplier = velocityMultiplier
        self.rotationAngle = Angle(degrees: totalAngle.wrappedValue)
        self.onAngleChanged = onAngleChanged
        self.animation = animation
        self._stoppingAnimation = stoppingAnimation
        self._autoRotationSpeed = autoRotationSpeed
        self._autoRotationEnabled = autoRotationEnabled
    }
    
    private func startAutoRotation() {
            guard autoRotationEnabled, autoRotationTimer == nil else { return }
            autoRotationTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
                let deltaRotation = autoRotationSpeed / 60.0
                let newRotation = rotationAngle.degrees + deltaRotation
                rotationAngle = Angle(degrees: newRotation)
                totalAngle = newRotation //+ Double(totalAngle) * 360
                onAngleChanged(newRotation) //+ Double(totalAngle) * 360)
            }
        }
    private func stopAutoRotation() {
            autoRotationTimer?.invalidate()
            autoRotationTimer = nil
        }
    
    
    
    public func body(content: Content) -> some View {
        GeometryReader { geometry in
            
            content
            
            /// The ".background" modifier and the ".onPreferenceChange" update the automatic frame calculation of the content.
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(key: FrameSizeKeyValueAutoRotationInertia.self, value: geometry.size)
                    }
                )
                .onPreferenceChange(FrameSizeKeyValueAutoRotationInertia.self) { newSize in
                    viewSize = newSize
                }
            /// The ".position" modifier fix the center of the content.
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            /// The ".rotationEffect" modifier is necessary for the gesture functions, it applies the specific rotation.
                .rotationEffect(rotationAngle + gestureRotation, anchor: .center)
            
                .onChange(of: totalAngle) { newValue in
                    if !isDragged && isSpinning {
                        if let animation = animation {
                            withAnimation(animation) {
                                rotationAngle = Angle(degrees: newValue)
                                if stoppingAnimation {
                                    timer?.invalidate()
                                    isSpinning = false
                                }
                                //stoppingAnimation = false
                            }
                        } else {
                            rotationAngle = Angle(degrees: newValue)
                            if stoppingAnimation {
                                timer?.invalidate()
                                isSpinning = false
                            }
                            //stoppingAnimation = false
                        }
                    }
                    if !isDragged && !isSpinning {
                        if let animation = animation {
                            withAnimation(animation) {
                                rotationAngle = Angle(degrees: newValue)
                            }
                        } else {
                            rotationAngle = Angle(degrees: newValue)
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
                            stopAutoRotation()
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
                            previousAngle = dragAngle.degrees
                            
                            // Update totalAngle without adding fullRotations * 360
                            totalAngle += angleDifference
                            onAngleChanged(totalAngle)
                        }
                        .onEnded { value in
                            if autoRotationEnabled {
                                startAutoRotation()
                            }
                            previousAngle = 0
                            isDragged = false
                            isSpinning = true
                            rotationAngle += gestureRotation
                            let velocity = CGPoint(x: value.predictedEndLocation.x - value.location.x, y: value.predictedEndLocation.y - value.location.y)
                            lastVelocity = sqrt(pow(velocity.x, 2) + pow(velocity.y, 2)) * velocityMultiplier
                            onAngleChanged(rotationAngle.degrees)
                            if abs(velocity.x) > rotationThreshold || abs(velocity.y) > rotationThreshold {
                                isSpinning = true
                                timer?.invalidate()
                                timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                                    let angle = Angle(degrees: Double(lastVelocity) * rotationDirection)
                                    rotationAngle += angle
                                    onAngleChanged(rotationAngle.degrees)
                                    lastVelocity *= (1 - friction)
                                    if lastVelocity < 0.1 {
                                        timer.invalidate()
                                        isSpinning = false
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
                    if autoRotationEnabled {
                        startAutoRotation()
                    }
                }
            
            /// The ".onDisappear" modifier is necessary for the gesture functions.
                .onDisappear {
                    timer?.invalidate()
                    stopAutoRotation()
                }
                .onChange(of: autoRotationEnabled) { newValue in
                    if newValue {
                        startAutoRotation()
                    } else {
                        stopAutoRotation()
                    }
                }
        }
        
        /// This ".frame" modifier ensures that the content is at the center of the view always.
        .frame(width: viewSize.width, height: viewSize.height)
    }
    
    /// The function calculateRotationAngle calculates the angle according to the finger movement.
    private func calculateRotationAngle(value: DragGesture.Value, geometry: GeometryProxy) -> Angle {
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
struct FrameSizeKeyValueAutoRotationInertia: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

public extension View {
    func valueAutoRotationInertia(
        totalAngle: Binding<Double>,
        friction: Binding<CGFloat>? = nil,
        onAngleChanged: @escaping (Double) -> Void,
        velocityMultiplier: Binding<CGFloat>? = nil,
        animation: Animation? = nil,
        stoppingAnimation: Binding<Bool>? = nil,
        autoRotationSpeed: Binding<Double>? = nil,
        autoRotationEnabled: Binding<Bool>? = nil
    ) -> some View {
        let effect = ValueAutoRotationInertia(
            totalAngle: totalAngle,
            friction: friction ?? .constant(0.1),
            velocityMultiplier: velocityMultiplier ?? .constant(0.1),
            animation: animation,
            onAngleChanged: onAngleChanged,
            stoppingAnimation: stoppingAnimation ?? .constant(false),
            autoRotationSpeed: autoRotationSpeed ?? .constant(40.0),
            autoRotationEnabled: autoRotationEnabled ?? .constant(true)
        )
        return self.modifier(effect)
    }
}
