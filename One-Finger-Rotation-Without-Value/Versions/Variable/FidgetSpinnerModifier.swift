//
//  FidgetSpinnerModifier.swift
//  One-Finger-Rotation-Framework
//
//  Created by Matteo Fontana on 23/04/23.
//

import SwiftUI

struct FidgetSpinnerEffect: ViewModifier {
     
    /// Variable for the angle of rotation of the Fidget Spinner.
    @State private var rotationAngle: Angle = .degrees(0.0)
    
    /// Variable for the gesture rotation.
    @GestureState private var gestureRotation: Angle = .zero
    
    /// Variable for the last speed of the finger on the screen.
    @State private var lastVelocity: CGFloat = 0
    
    /// Variable to check if the Fidget Spinner is spinning.
    @State private var isSpinning = false
    
    /// Variable for the timer of the spinning action.
    @State private var timer: Timer?
    
    /// Variable for friction, useful for slider, value should have an interval from 0.000  to 1.000.
    @State var friction: CGFloat
    
    /// Velocity multiplier, stock value should be 0.1, value should range from 0.0 to 1.0.
    @State var velocityMultiplier: CGFloat
    
    /// viewSize is needed for the calculation of the Width and Height of the View.
    @State private var viewSize: CGSize = .zero
    
    /// Threshold value.
    let rotationThreshold: CGFloat = 1.0
    
    /// Initialization of three declarable and optional values.
    init(friction: CGFloat = 0.995, velocityMultiplier: CGFloat = 0.1, rotationAngle: Angle = .degrees(0.0)) {
            _friction = State(initialValue: friction)
            _velocityMultiplier = State(initialValue: velocityMultiplier)
            _rotationAngle = State(initialValue: rotationAngle)
    }
    
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
            
            /// The ".background" modifier and the ".onPreferenceChange" update the automatic frame calculation of the content.
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(key: FrameSizeKey.self, value: geometry.size)
                    }
                )
                .onPreferenceChange(FrameSizeKey.self) { newSize in
                    viewSize = newSize
                }
            /// The ".position" modifier fix the center of the content.
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            /// The ".rotationEffect" modifier is necessary for the gesture functions, it applies the specific rotation.
                .rotationEffect(rotationAngle + gestureRotation, anchor: .center)
            
            /// The ".gesture" modifier is necessary for the gesture functions.
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .updating($gestureRotation) { value, state, _ in
                            state = calculateRotationAngle(value: value, geometry: geometry)
                        }
                        .onChanged { _ in
                            timer?.invalidate()
                        }
                        .onEnded { value in
                            let angleDifference = calculateRotationAngle(value: value, geometry: geometry)
                            rotationAngle = rotationAngle + angleDifference
                            let velocity = CGPoint(x: value.predictedEndLocation.x - value.location.x, y: value.predictedEndLocation.y - value.location.y)
                            lastVelocity = sqrt(pow(velocity.x, 2) + pow(velocity.y, 2)) * velocityMultiplier
                            
                            if abs(velocity.x) > rotationThreshold || abs(velocity.y) > rotationThreshold {
                                isSpinning = true
                                timer?.invalidate()
                                timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                                    let rotationDirection = angleDifference >= .zero ? 1.0 : -1.0
                                    let angle = Angle(degrees: Double(lastVelocity) * rotationDirection)
                                    rotationAngle += angle
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
struct FrameSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
