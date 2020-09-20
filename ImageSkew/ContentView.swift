//
//  ContentView.swift
//  ImageSkew
//
//  Created by Ben Edelstein on 7/19/20.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var motionManager = MotionManager()
    private let maxDegrees: Double = 30 // clip max rotation angle
    private let rotationScale: Double = 0.5
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            VStack {
                RoundedRectangle(cornerRadius: 10)
                    .padding()
                    .foregroundColor(.blue)
                    .frame(width: 300, height: 600)
                    .rotation3DEffect(
                        max(min(Angle.radians(motionManager.magnitude * rotationScale), Angle.degrees(maxDegrees)), Angle.degrees(-maxDegrees))
                        ,
                        axis: (x: CGFloat(motionManager.x), y: CGFloat(motionManager.y), z: 0.0)
                    )
                    .shadow(radius: 10)
                Button(action: {
                    withAnimation(.spring()) {
                        motionManager.stopUpdates()
                    }
                }) {
                    Label("Stop Updates", systemImage: "octagon.fill")
                        .font(.title)
                }
                .padding()
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(5)
                .shadow(radius: 10, y: 5)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
