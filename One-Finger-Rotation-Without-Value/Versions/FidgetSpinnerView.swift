//
//  RotatableElement.swift
//  One-Finger-Rotation
//
//  Created by Matteo Fontana on 23/04/23.
//
import SwiftUI

struct FidgetSpinnerView: View {
    @State private var rotationAngle: Angle = .zero
    @GestureState private var gestureRotation: Angle = .zero
    @State private var lastVelocity: CGFloat = 0
    @State private var isSpinning = false
    @State private var timer: Timer?

    @State var friction: CGFloat = 0.994

    // Add a threshold value
    let rotationThreshold: CGFloat = 1.0

    // Add a velocity multiplier
    @State var velocityMultiplier: CGFloat = 0.1

    var body: some View {
        VStack {
            Spacer()
            GeometryReader { geometry in
                Image("FidgetSpinner")
                    .resizable()
                    .frame(width: 400, height: 400)
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .rotationEffect(rotationAngle + gestureRotation, anchor: .center)
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
                    .onAppear {
                        timer?.invalidate()
                    }
                    .onDisappear {
                        timer?.invalidate()
                    }
            }
            Spacer()
            VStack {
                Text("Friction: \((friction-0.9)*1000, specifier: "%.0f")")
                    .padding(.bottom, 4)
                Slider(value: $friction, in: 0.90...0.999)
                    .padding([.leading, .trailing], 16)
                Text("Velocity Multiplier: \(velocityMultiplier, specifier: "%.1f")")
                    .padding(.bottom, 4)
                Slider(value: $velocityMultiplier, in: 0.1...5.0)
                    .padding([.leading, .trailing], 16)
            }
        }
    }

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

//The implementation of this code works, but is there a way to create two sliders? One for the friction and one for the velocity multiplier?
