//
//  FlipExpandView.swift
//  BluetoothDeviceManager
//
//  Created by Jerónimo Valli on 5/12/25.
//

import SwiftUI

struct FlipExpandView<Front: View, Back: View>: View {
    var front: () -> Front
    var back: () -> Back
    var flipDuration: Double = 0.4
    
    @State private var flipped: Bool = false
    @State private var flipAngle: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if !flipped {
                    front()
                        .opacity(flipAngle < 90 ? 1 : 0)
                } else {
                    ZStack(alignment: .topTrailing) {
                        back()
                    }
                    .opacity(flipAngle > 90 ? 1 : 0)
                }
            }
            .rotation3DEffect(
                .degrees(flipAngle),
                axis: (x: 0.0, y: 1.0, z: 0.0),
                perspective: 0.5
            )
            .onTapGesture {
                if !flipped {
                    animateFlip()
                } else {
                    flipBack()
                }
            }
        }
    }
    
    private func animateFlip() {
        withAnimation(.easeInOut(duration: flipDuration)) {
            flipped.toggle()
            flipAngle += 180
        }
    }
    
    private func flipBack() {
        withAnimation(.easeInOut(duration: flipDuration)) {
            flipped.toggle()
            flipAngle -= 180
        }
    }
}
