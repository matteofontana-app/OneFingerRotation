//
//  KnobInertia.swift
//  One-Finger-Rotation-Without-Value
//
//  Created by Matteo Fontana on 26/04/23.
//

import SwiftUI

struct KnobInertia: View {
    @State private var rotationAngle: Angle = .degrees(-90) // Set the initial rotation angle
    @State private var previousAngle: Double = 0
    @State private var knobValue: Double = 0.5 // Set the initial knob value
    let minAngle: Double = -180
    let maxAngle: Double = 0

    var body: some View {
        VStack {
            Text("Value: \(knobValue, specifier: "%.4f")")
                .font(.largeTitle)
                .padding()

            ZStack{
                Circle()
                    .foregroundColor(.green)
                VStack{
                    Rectangle()
                        .frame(width: 20, height: 80)
                    Spacer()
                }
            }
                .frame(width: 200, height: 200)
                .foregroundColor(.red)
                .rotationEffect(rotationAngle)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let dragAngle = angleForDrag(value: value)
                            let angleDifference = dragAngle.degrees - previousAngle

                            let currentAngle = rotationAngle.degrees + angleDifference
                            let clampedAngle = min(max(minAngle, currentAngle), maxAngle)

                            if abs(angleDifference) < 90 { // Add this line to check the angleDifference threshold
                                if minAngle...maxAngle ~= clampedAngle {
                                    rotationAngle = Angle(degrees: clampedAngle)
                                    knobValue = (clampedAngle - minAngle) / (maxAngle - minAngle)
                                }
                            }

                            previousAngle = dragAngle.degrees
                        }
                        .onEnded { _ in
                            previousAngle = 0
                        }
                )

            Button("Reset Rotation") {
                withAnimation(.easeInOut(duration: 0.1)) {
                    rotationAngle = .degrees(0)
                    knobValue = 0.5
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

struct KnobInertia_Previews: PreviewProvider {
    static var previews: some View {
        KnobInertia()
    }
}
