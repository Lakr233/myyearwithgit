//
//  SpringInterpolation2D.swift
//  SpringInterpolation
//
//  Created by QAQ on 2023/12/3.
//

import Foundation

public struct SpringInterpolation2D {
    public var x: SpringInterpolation
    public var y: SpringInterpolation

    public struct Vec2D {
        public let x: Double
        public let y: Double

        public init(x: Double, y: Double) {
            self.x = x
            self.y = y
        }
    }

    public init(
        _ config: SpringInterpolation.Configuration = .init(),
        _ context: SpringInterpolation.Context = .init()
    ) {
        x = .init(config: config, context: context)
        y = .init(config: config, context: context)
    }

    @discardableResult
    public mutating func update(withDeltaTime interval: TimeInterval) -> Vec2D {
        let retX = x.update(withDeltaTime: interval)
        let retY = y.update(withDeltaTime: interval)
        return .init(x: retX, y: retY)
    }

    public mutating func setCurrent(_ pos: Vec2D, vel: Vec2D = .init(x: 0, y: 0)) {
        x.setCurrent(pos.x, vel.x)
        y.setCurrent(pos.y, vel.y)
    }

    public mutating func setTarget(_ pos: Vec2D) {
        x.setTarget(pos.x)
        y.setTarget(pos.y)
    }
}
