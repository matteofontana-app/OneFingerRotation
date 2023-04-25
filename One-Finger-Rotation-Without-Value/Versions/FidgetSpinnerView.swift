//
//  FidgetSpinnerView.swift
//  Fidget Spinner View
//
//  Created by Matteo Fontana on 23/04/23.
//
import SwiftUI

struct FidgetSpinnerView: View {
    /// Variable for the angle of rotation of the Fidget Spinner
    @State private var rotationAngle: Angle = .zero
    /// Variable for the gesture rotation
    @GestureState private var gestureRotation: Angle = .zero
    /// Variable for the last speed of the finger on the screen
    @State private var lastVelocity: CGFloat = 0
    /// Variable to check if the Fidget Spinner is spinning
    @State private var isSpinning = false
    /// Variable for the timer of the spinning action
    @State private var timer: Timer?

    /// Variable for friction, useful for slider
    @State var friction: CGFloat = 0.994
    
    /// Velocity multiplier
    @State var velocityMultiplier: CGFloat = 0.1

    /// Threshold value
    let rotationThreshold: CGFloat = 1.0

    var body: some View {
        VStack {
            
            Spacer()
            
            /// Geometry Reader is necessary for the use of the gesture
            GeometryReader { geometry in
                Image("FidgetSpinner")
                    .resizable()
                    .frame(width: 400, height: 400)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                    /// The ".rotationEffect" modifier is necessary for the gesture functions
                    .rotationEffect(rotationAngle + gestureRotation, anchor: .center)
                
                    /// The ".gesture" modifier is necessary for the gesture functions
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
                
                    /// The ".onAppear" modifier is necessary for the gesture functions
                    .onAppear {
                        timer?.invalidate()
                    }
                
                    /// The ".onDisappear" modifier is necessary for the gesture functions
                    .onDisappear {
                        timer?.invalidate()
                    }
            }
            
            Spacer()
            
            /// The two sliders for the friction and the Velocity Multiplier
            Text("Friction: \((friction-0.8)*1000, specifier: "%.3f")")
                .padding(.bottom, 4)
            Slider(value: $friction, in: 0.80...0.999)
                .padding([.leading, .trailing], 16)
            Text("Velocity Multiplier: \(velocityMultiplier, specifier: "%.3f")")
                .padding(.bottom, 4)
            Slider(value: $velocityMultiplier, in: 0.001...5.000)
                .padding([.leading, .trailing], 16)
            
            Spacer()
        }
    }

    /// Function to calculate the angle rotation of the Fidget Spinner while moving and at the end of a gesture interaction
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

struct FidgetSpinnerView_Previews: PreviewProvider {
    static var previews: some View {
        FidgetSpinnerView()
    }
}
