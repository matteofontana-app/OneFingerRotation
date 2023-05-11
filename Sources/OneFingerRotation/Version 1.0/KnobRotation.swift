//
//  ValueRotation.swift
//  One-Finger-Rotation
//
//  Created by Matteo Fontana on 23/04/23.
//

import SwiftUI

public struct KnobRotation: ViewModifier {
    @State private var rotationAngle: Angle = .degrees(0)
    @Binding var knobValue: Double
    @State private var previousAngle: Double = 0
    var onKnobValueChanged: (Double) -> Void
    var animation: Animation?
    @State private var isDragged: Bool = false
    @State private var fullRotations: Int = 0
    @State var minAngle: Double
    @State var maxAngle: Double
    
    init(knobValue: Binding<Double>, minAngle: Double, maxAngle: Double, onKnobValueChanged: @escaping (Double) -> Void, animation: Animation? = nil) {
            self._knobValue = knobValue
            self.minAngle = minAngle
            self.maxAngle = maxAngle
            rotationAngle = Angle(degrees: minAngle+(maxAngle-minAngle)*knobValue.wrappedValue)
            self.onKnobValueChanged = onKnobValueChanged
            self.animation = animation
        }
    
    @State private var viewSize: CGSize = .zero
    
    public func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(key: FrameSizeKeyKnobRotation.self, value: geometry.size)
                    }
                )
                .onPreferenceChange(FrameSizeKeyKnobRotation.self) { newSize in
                    viewSize = newSize
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .rotationEffect(rotationAngle, anchor: .center)
                .onChange(of: knobValue) { newValue in
                    if !isDragged {
                        if let animation = animation {
                            withAnimation(animation) {
                                rotationAngle = Angle(degrees: minAngle+(maxAngle-minAngle)*$knobValue.wrappedValue)
                            }
                        } else {
                            rotationAngle = Angle(degrees: minAngle+(maxAngle-minAngle)*$knobValue.wrappedValue)
                        }
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isDragged = true
                            let dragAngle = angleForDrag(value: value, geometry: geometry)
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
                            isDragged = false
                            previousAngle = 0
                        }
                )
        }
        .frame(width: viewSize.width, height: viewSize.height)
    }
    
    private func angleForDrag(value: DragGesture.Value, geometry: GeometryProxy) -> Angle {
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

struct FrameSizeKeyKnobRotation: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

extension View {
    func knobRotation(
        knobValue: Binding<Double>,
        minAngle: Double? = nil,
        maxAngle: Double? = nil,
        onKnobValueChanged: @escaping (Double) -> Void,
        animation: Animation? = nil) -> some View
    {
        self.modifier(
            KnobRotation(
                knobValue: knobValue,
                minAngle: minAngle ?? -90,
                maxAngle: maxAngle ?? 90,
                onKnobValueChanged: onKnobValueChanged,
                animation: animation))
    }
}
 
