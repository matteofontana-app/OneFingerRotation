//
//  ValueRotation.swift
//  One-Finger-Rotation
//
//  Created by Matteo Fontana on 23/04/23.
//

import SwiftUI

struct ValueRotation: View {
    @State private var rotationAngle: Angle = .degrees(0)
    @State private var previousAngle: Double = 0
    @State private var totalAngle: Double = 0
    @State private var fullRotations: Int = 0

    var body: some View {
        VStack {
            Text("\(totalAngle/360, specifier: "%.4f")")
                .font(.largeTitle)
                .padding()

            Rectangle()
                .frame(width: 200, height: 200)
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
                        }
                        .onEnded { _ in
                            previousAngle = 0
                        }
                )

            Button("Reset Rotation") {
                withAnimation(.easeInOut(duration: 0.1)) {
                    rotationAngle = .degrees(0)
                    totalAngle = 0
                    fullRotations = 0
                }
            }
            .padding(.top, 20)
        }
    }

    private func angleForDrag(value: DragGesture.Value) -> Angle {
        let center = CGPoint(x: 100, y: 100)
        let vector1 = CGPoint(x: value.startLocation.x - center.x, y: value.startLocation.y - center.y)
        let vector2 = CGPoint(x: value.location.x - center.x, y: value.location.y - center.y)

        let angle1 = atan2(vector1.y, vector1.x)
        let angle2 = atan2(vector2.y, vector2.x)

        return Angle(radians: Double(angle2 - angle1))
    }
}

struct ValueRotation_Previews: PreviewProvider {
    static var previews: some View {
        ValueRotation()
    }
}
