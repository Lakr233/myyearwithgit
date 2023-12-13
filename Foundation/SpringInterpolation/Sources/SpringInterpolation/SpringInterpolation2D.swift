//
//  SpringInterpolation2D.swift
//  SpringInterpolation
//
//  Created by QAQ on 2023/12/3.
//

import Foundation

public struct SpringInterpolation2D {
    public private(set) var springX: SpringInterpolation
    public private(set) var springY: SpringInterpolation

    public struct Vec2D {
        public let x: Double
        public let y: Double

        public init(x: Double, y: Double) {
            self.x = x
            self.y = y
        }
    }

    public var currentPos: Vec2D {
        .init(x: springX.currentPos, y: springY.currentPos)
    }

    public var currentVel: Vec2D {
        .init(x: springX.currentVel, y: springY.currentVel)
    }

    public var targetPos: Vec2D {
        .init(x: springX.targetPos, y: springY.targetPos)
    }

    public init(_ config: SpringInterpolation.Configuration = .init(fps: 60, angularFrequency: 2.0, dampingRatio: 1.0)) {
        springX = .init(config)
        springY = .init(config)
    }

    @discardableResult
    public mutating func tik() -> Vec2D {
        let retX = springX.tik()
        let retY = springY.tik()
        return .init(x: retX, y: retY)
    }

    public mutating func setCurrent(_ pos: Vec2D, vel _: Vec2D? = nil) {
        springX.setCurrent(pos.x)
        springY.setCurrent(pos.y)
    }

    public mutating func setTarget(_ pos: Vec2D) {
        springX.setTarget(pos.x)
        springY.setTarget(pos.y)
    }
}
