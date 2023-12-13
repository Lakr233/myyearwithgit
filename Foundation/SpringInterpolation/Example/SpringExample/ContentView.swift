//
//  ContentView.swift
//  SpringExample
//
//  Created by QAQ on 2023/12/3.
//

import Combine
import SpringInterpolation
import SwiftUI

let ball: Double = 16

struct ContentView: View {
    @State var target: CGPoint = .zero
    @State var offset: CGPoint = .zero

    @State var spring: SpringInterpolation2D
    let timer: Publishers.Autoconnect<Timer.TimerPublisher>

    init() {
        let fps = 60
        let spring = SpringInterpolation2D(.init(fps: fps))
        self.spring = spring
        let timer = Timer.publish(every: 1 / Double(fps), on: .main, in: .common).autoconnect()
        self.timer = timer
    }

    var body: some View {
        ZStack {
            GeometryReader { r in
                Rectangle()
                    .opacity(0)
                    .onChange(of: r.size) { _, newValue in
                        let x = newValue.width / 2 - ball / 2
                        let y = newValue.height / 2 - ball / 2
                        spring.setCurrent(.init(x: x, y: y))
                        let point = CGPoint(x: x, y: y)
                        target = point
                        offset = point

                        print("[*] setting new point \(point)")
                    }
                Circle()
                    .frame(width: ball, height: ball)
                    .foregroundStyle(.green.opacity(0.5))
                    .offset(x: offset.x, y: offset.y)
                Circle()
                    .frame(width: ball, height: ball)
                    .foregroundStyle(.red.opacity(0.5))
                    .offset(x: target.x, y: target.y)
                    .foregroundStyle(.red.opacity(0.5))
                    .gesture(DragGesture()
                        .onChanged { gesture in
                            target = .init(x: gesture.location.x - 5, y: gesture.location.y - 5)
                        }
                    )
            }
        }
        .onReceive(timer) { _ in
            spring.setTarget(.init(x: target.x, y: target.y))
            let ret = spring.tik()
            offset = .init(x: ret.x, y: ret.y)
        }
        .padding()
    }
}
