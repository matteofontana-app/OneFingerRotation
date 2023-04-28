//
//  FidgetSpinnerModifier.swift
//  One-Finger-Rotation-Framework
//
//  Created by Matteo Fontana on 23/04/23.
//

import SwiftUI

struct FidgetSpinnerValueEffect: ViewModifier {
    @State private var rotationAngle: Angle = .degrees(0)
    @GestureState private var gestureRotation: Angle = .zero
    @State private var lastVelocity: CGFloat = 0
    @State private var isSpinning = false
    @State private var timer: Timer?
    @Binding var friction: CGFloat
    @Binding var velocityMultiplier: CGFloat
    @State private var viewSize: CGSize = .zero
    var animation: Animation?
    @State private var isDragged: Bool = false
    let rotationThreshold: CGFloat = 12.0
    var onAngleChanged: (Double) -> Void
    @Binding var totalAngle: Double
    
    
    
    /// Initialization of three declarable and optional values.
    init(totalAngle: Binding<Double>, friction: Binding<CGFloat> = .constant(0.995), velocityMultiplier: Binding<CGFloat> = .constant(0.1), rotationAngle: Angle = .degrees(0.0), animation: Animation? = nil, onAngleChanged: @escaping (Double) -> Void) {
        self._totalAngle = totalAngle
        self._friction = friction
        self._velocityMultiplier = velocityMultiplier
        self.rotationAngle = Angle(degrees: totalAngle.wrappedValue)
        self.onAngleChanged = onAngleChanged
        self.animation = animation
    }
    
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            
            content
            
            /// The ".background" modifier and the ".onPreferenceChange" update the automatic frame calculation of the content.
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(key: FrameSizeKeyFidgetSpinnerValue.self, value: geometry.size)
                    }
                )
                .onPreferenceChange(FrameSizeKeyFidgetSpinnerValue.self) { newSize in
                    viewSize = newSize
                }
            /// The ".position" modifier fix the center of the content.
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            /// The ".rotationEffect" modifier is necessary for the gesture functions, it applies the specific rotation.
                .rotationEffect(rotationAngle + gestureRotation, anchor: .center)
            
                .onChange(of: totalAngle) { newValue in
                    if !isDragged {
                        if let animation = animation {
                            withAnimation(animation) {
                                rotationAngle = Angle(degrees: newValue)
                            }
                        } else {
                            rotationAngle = Angle(degrees: newValue)
                        }
                    }
                }
            
            /// The ".gesture" modifier is necessary for the gesture functions.
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .updating($gestureRotation) { value, state, _ in
                            let previousState = state
                            state = calculateRotationAngle(value: value, geometry: geometry)
                            let deltaAngle = state.degrees - previousState.degrees
                            if abs(deltaAngle) > 180 {
                                let adjustedDeltaAngle = deltaAngle > 0 ? deltaAngle - 360 : deltaAngle + 360
                                rotationAngle.degrees += adjustedDeltaAngle
                            } else {
                                rotationAngle.degrees += deltaAngle
                            }
                            onAngleChanged(rotationAngle.degrees)
                            
                            // Invalidate the timer to stop inertia when dragging
                            timer?.invalidate()
                            isSpinning = false
                        }
                        .onChanged { _ in
                            isDragged = true
                            timer?.invalidate()
                        }
                        .onEnded { value in
                            isDragged = false
                            let angleDifference = calculateRotationAngle(value: value, geometry: geometry)
                            rotationAngle = rotationAngle + angleDifference
                            
                            // Update the rotationAngle and gestureRotation values
                            rotationAngle += gestureRotation
                            
                            let velocity = CGPoint(x: value.predictedEndLocation.x - value.location.x, y: value.predictedEndLocation.y - value.location.y)
                            lastVelocity = sqrt(pow(velocity.x, 2) + pow(velocity.y, 2)) * velocityMultiplier
                            onAngleChanged(rotationAngle.degrees)
                            if abs(velocity.x) > rotationThreshold || abs(velocity.y) > rotationThreshold {
                                isSpinning = true
                                timer?.invalidate()
                                timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                                    let rotationDirection = angleDifference >= .zero ? 1.0 : -1.0
                                    let angle = Angle(degrees: Double(lastVelocity) * rotationDirection)
                                    rotationAngle += angle
                                    onAngleChanged(rotationAngle.degrees)
                                    lastVelocity *= friction
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
struct FrameSizeKeyFidgetSpinnerValue: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

extension View {
    func fidgetSpinnerValueEffect(totalAngle: Binding<Double>, friction: Binding<CGFloat>? = nil, onAngleChanged: @escaping (Double) -> Void, velocityMultiplier: Binding<CGFloat>? = nil, animation: Animation? = nil) -> some View {
        let effect = FidgetSpinnerValueEffect(
            totalAngle: totalAngle,
            friction: friction ?? .constant(0.995),
            velocityMultiplier: velocityMultiplier ?? .constant(0.1),
            animation: animation,
            onAngleChanged: onAngleChanged
        )
        return self.modifier(effect)
    }
}
