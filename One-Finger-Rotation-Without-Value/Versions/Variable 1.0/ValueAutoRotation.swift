//
//  ValueAutoRotation.swift
//  One-Finger-Rotation-Without-Value
//
//  Created by Matteo Fontana on 01/05/23.
//

import SwiftUI

struct ValueAutoRotation: ViewModifier {
    @State private var rotationAngle: Angle = .degrees(0)
    @State private var previousAngle: Double = 0
    @Binding var totalAngle: Double
    var onAngleChanged: (Double) -> Void
    var animation: Animation?
    @State private var isDragged: Bool = false
    @State private var fullRotations: Int = 0
    // Add new properties for auto rotation
    @Binding var autoRotationSpeed: Double
    @Binding var autoRotationEnabled: Bool
    @State private var autoRotationTimer: Timer? = nil
    
    init(totalAngle: Binding<Double>, onAngleChanged: @escaping (Double) -> Void, animation: Animation? = nil, autoRotationSpeed: Binding<Double>, autoRotationEnabled: Binding<Bool>) {
        self._totalAngle = totalAngle
        rotationAngle = Angle(degrees: totalAngle.wrappedValue)
        self.onAngleChanged = onAngleChanged
        self.animation = animation
        self._autoRotationSpeed = autoRotationSpeed
        self._autoRotationEnabled = autoRotationEnabled
    }

    private func startAutoRotation() {
            guard autoRotationEnabled, autoRotationTimer == nil else { return }
            autoRotationTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
                let deltaRotation = autoRotationSpeed / 60.0
                let newRotation = rotationAngle.degrees + deltaRotation
                rotationAngle = Angle(degrees: newRotation)
                totalAngle = newRotation + Double(fullRotations) * 360
                onAngleChanged(newRotation + Double(fullRotations) * 360)
            }
        }
    private func stopAutoRotation() {
            autoRotationTimer?.invalidate()
            autoRotationTimer = nil
        }
    
    @State private var viewSize: CGSize = .zero
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(key: FrameSizeKeyValueAutoRotation.self, value: geometry.size)
                    }
                )
                .onPreferenceChange(FrameSizeKeyValueAutoRotation.self) { newSize in
                    viewSize = newSize
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                .rotationEffect(rotationAngle, anchor: .center)
                .onChange(of: totalAngle) { newValue in
                    if !isDragged {
                        if let animation = animation {
                            withAnimation(animation) {
                                rotationAngle = Angle(degrees: newValue)
                                fullRotations = 0
                            }
                        } else {
                            rotationAngle = Angle(degrees: newValue)
                            fullRotations = 0
                        }
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            stopAutoRotation()

                            isDragged = true
                            let dragAngle = angleForDrag(value: value, geometry: geometry)
                            let angleDifference = dragAngle.degrees - previousAngle
                            
                            if angleDifference > 180 {
                                fullRotations -= 1
                            } else if angleDifference < -180 {
                                fullRotations += 1
                            }
                            
                            let currentAngle = rotationAngle.degrees + angleDifference
                            rotationAngle = Angle(degrees: currentAngle)
                            previousAngle = dragAngle.degrees
                            
                            let totalRotationAngle = currentAngle + Double(fullRotations) * 360
                            onAngleChanged(totalRotationAngle)
                            totalAngle = totalRotationAngle
                        }
                        .onEnded { _ in
                            if autoRotationEnabled {
                                startAutoRotation()
                            }
                            isDragged = false
                            previousAngle = 0
                        }
                )
                .onAppear {
                    if autoRotationEnabled {
                        startAutoRotation()
                    }
                }
                .onDisappear {
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

extension View {
    func valueAutoRotation(
        totalAngle: Binding<Double>,
        onAngleChanged: @escaping (Double) -> Void,
        animation: Animation? = nil,
        autoRotationSpeed: Binding<Double>? = nil,
        autoRotationEnabled: Binding<Bool>? = nil
    ) -> some View {
        self.modifier(
            ValueAutoRotation(
                totalAngle: totalAngle,
                onAngleChanged: onAngleChanged,
                animation: animation,
                autoRotationSpeed: autoRotationSpeed ?? .constant(20.0),
                autoRotationEnabled: autoRotationEnabled ?? .constant(true)
            )
        )
    }
}

struct FrameSizeKeyValueAutoRotation: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
 

