//
//  SpringInterpolation+Configuration.swift
//  SpringInterpolation
//
//  Created by QAQ on 2023/12/3.
//

import Foundation

public extension SpringInterpolation {
    struct Configuration {
        public let deltaTime: Double
        public let angularFrequency: Double
        public let dampingRatio: Double

        public static let defaultDeltaTime = 0.01
        public static let defaultAngularFrequency: Double = 4
        public static let defaultDampingRatio: Double = 1

        public init(
            fps: Int,
            angularFrequency: Double = defaultAngularFrequency,
            dampingRatio: Double = defaultDampingRatio
        ) {
            deltaTime = 1.0 / Double(fps)
            self.angularFrequency = angularFrequency
            self.dampingRatio = dampingRatio

            assert(angularFrequency > 0)
            assert(dampingRatio > 0)
        }

        public init(
            deltaTime: Double = defaultDeltaTime,
            angularFrequency: Double = defaultAngularFrequency,
            dampingRatio: Double = defaultDampingRatio
        ) {
            self.deltaTime = deltaTime
            self.angularFrequency = angularFrequency
            self.dampingRatio = dampingRatio

            assert(angularFrequency > 0)
            assert(dampingRatio > 0)
        }
    }
}
