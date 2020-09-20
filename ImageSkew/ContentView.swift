//
//  ContentView.swift
//  ImageSkew
//
//  Created by Ben Edelstein on 7/19/20.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var motionManager = MotionManager()
    private var maxDegrees: Double = 30
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
                        max(min(Angle.radians(motionManager.magnitude / 2), Angle.degrees(maxDegrees)), Angle.degrees(-maxDegrees))
                        ,
                        axis: (x: CGFloat(-1 * motionManager.x), y: CGFloat(-1 * motionManager.y), z: 0.0),
                        anchor: .center,
                        anchorZ: 0,
                        perspective: 1.0
                    )
                    .shadow(radius: 10)
                Button(action: {
                    withAnimation(.spring()) {
                        motionManager.stopUpdates()
                    }
                }) {
                    Label("Stop Updates", systemImage: "octagon.fill")
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
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
