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

    @State var springEngine: SpringInterpolation2D = .init()
    @State var lastUpdate: Date = .init()
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()

    @AppStorage("dampingRatio")
    var dampingRatio: Double = SpringInterpolation.Configuration.defaultDampingRatio
    @AppStorage("angularFrequency")
    var angularFrequency: Double = SpringInterpolation.Configuration.defaultAngularFrequency

    var body: some View {
        VStack(spacing: 0) {
            Text("Spring Interpolation Engine 2D")
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .padding()
            Divider()
            panel.padding()
            Divider()
            control.padding()
            Divider()
            runtimeDiag.padding()
        }
        .ignoresSafeArea()
        .onAppear { updateConfig() }
        .onChange(of: dampingRatio) { _, _ in
            updateConfig()
        }
        .onChange(of: angularFrequency) { _, _ in
            updateConfig()
        }
        .onReceive(timer) { _ in
            defer { lastUpdate = .init() }
            springEngine.setTarget(.init(x: target.x, y: target.y))
            let ret = springEngine.update(withDeltaTime: -lastUpdate.timeIntervalSinceNow)
            offset = .init(x: ret.x, y: ret.y)
        }
    }

    var panel: some View {
        GeometryReader { r in
            Rectangle()
                .opacity(0)
                .onChange(of: r.size) { _, newValue in
                    let x = newValue.width / 2 - ball / 2
                    let y = newValue.height / 2 - ball / 2
                    springEngine.setCurrent(.init(x: x, y: y))
                    let point = CGPoint(x: x, y: y)
                    target = point
                    offset = point
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

    var control: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Slider(value: $dampingRatio, in: 0 ... 1, step: 0.1) {
                    Text("Damping Ratio \(dampingRatio, specifier: "%.2f")")
                        .frame(width: 200, alignment: .leading)
                } onEditingChanged: { _ in }
                Slider(value: $angularFrequency, in: 0 ... 10, step: 0.25) {
                    Text("Angular Frequency \(angularFrequency, specifier: "%.2f")")
                        .frame(width: 200, alignment: .leading)
                } onEditingChanged: { _ in }
            }
        }
        .font(.system(.footnote, design: .monospaced, weight: .regular))
    }

    var runtimeDiag: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("x.pos")
                    Spacer()
                    Text("\(springEngine.x.context.currentPos)")
                }
                HStack {
                    Text("x.vel")
                    Spacer()
                    Text("\(springEngine.x.context.currentVel)")
                }
                HStack {
                    Text("x.target")
                    Spacer()
                    Text("\(springEngine.x.context.targetPos)")
                }
            }
            Spacer().padding(.horizontal)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("y.pos")
                    Spacer()
                    Text("\(springEngine.y.context.currentPos)")
                }
                HStack {
                    Text("y.vel")
                    Spacer()
                    Text("\(springEngine.y.context.currentVel)")
                }
                HStack {
                    Text("y.target")
                    Spacer()
                    Text("\(springEngine.y.context.targetPos)")
                }
            }
        }
        .font(.system(.footnote, design: .monospaced, weight: .regular))
    }

    func updateConfig() {
        springEngine.x.config.dampingRatio = dampingRatio
        springEngine.y.config.dampingRatio = dampingRatio
        springEngine.x.config.angularFrequency = angularFrequency
        springEngine.y.config.angularFrequency = angularFrequency
    }
}
