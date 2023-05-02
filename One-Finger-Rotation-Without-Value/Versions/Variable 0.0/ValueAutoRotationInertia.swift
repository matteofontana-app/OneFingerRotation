//
//  ValueAutoRotationInertia.swift
//  One-Finger-Rotation-Without-Value
//
//  Created by Matteo Fontana on 27/04/23.
//

import Foundation

import SwiftUI

struct ValueAutoRotationInertiaTest: View {
    @State private var rotationAngle: Angle = .degrees(0)
    @State private var previousAngle: Double = 0
    @State private var totalAngle: Double = 0
    @State private var fullRotations: Int = 0
    @State private var velocity: Double = 0
    @State private var timer: Timer? = nil

    let friction: Double = 0.95
    let velocityThreshold: Double = 1.5

    var body: some View {
        VStack {
            Text("\(totalAngle, specifier: "%.4f")")
                .font(.largeTitle)
                .padding()
            Spacer()
            Rectangle()
                .frame(width: 300, height: 300)
                .foregroundColor(.red)
                .rotationEffect(rotationAngle)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let dragAngle = angleForDrag(value: value)
                            let angleDifference = dragAngle.degrees - previousAngle

                            if angleDifference > 180 {
                                fullRotations -= 1
                            } else if angleDifference < -180 {
                                fullRotations += 1
                            }

                            let currentAngle = rotationAngle.degrees + angleDifference
                            rotationAngle = Angle(degrees: currentAngle)
                            totalAngle = Double(fullRotations) * 360 + currentAngle
                            previousAngle = dragAngle.degrees

                            velocity = angleDifference
                        }
                        .onEnded { _ in
                            previousAngle = 0
                            if abs(velocity) > velocityThreshold {
                                startInertiaEffect()
                            } else {
                                velocity = 0
                            }
                        }
                )
            Spacer()
            Button("Reset Rotation") {
                withAnimation(.easeInOut(duration: 0.1)) {
                    rotationAngle = .degrees(0)
                    totalAngle = 0
                    fullRotations = 0
                    velocity = 0
                    timer?.invalidate()
                }
            }
            .padding(.top, 20)
        }
    }

    private func angleForDrag(value: DragGesture.Value) -> Angle {
        let center = CGPoint(x: 150, y: 150)
        let vector1 = CGPoint(x: value.startLocation.x - center.x, y: value.startLocation.y - center.y)
        let vector2 = CGPoint(x: value.location.x - center.x, y: value.location.y - center.y)

        let angle1 = atan2(vector1.y, vector1.x)
        let angle2 = atan2(vector2.y, vector2.x)

        return Angle(radians: Double(angle2 - angle1))
    }

    private func startInertiaEffect() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            applyInertia()
        }
    }

    private func applyInertia() {
        let currentAngle = rotationAngle.degrees + velocity
        rotationAngle = Angle(degrees: currentAngle)
        totalAngle = Double(fullRotations) * 360 + currentAngle

        velocity *= friction

        if abs(velocity) < 0.01 {
            timer?.invalidate()
            velocity = 0
        }
    }
}
