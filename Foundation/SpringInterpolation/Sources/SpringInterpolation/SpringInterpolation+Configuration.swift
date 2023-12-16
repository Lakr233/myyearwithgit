//
//  SpringInterpolation+Configuration.swift
//  SpringInterpolation
//
//  Created by QAQ on 2023/12/3.
//

import Foundation

public extension SpringInterpolation {
    struct Configuration {
        public var angularFrequency: Double
        public var dampingRatio: Double

        public static let defaultAngularFrequency: Double = 4
        public static let defaultDampingRatio: Double = 1

        public init(
            angularFrequency: Double = defaultAngularFrequency,
            dampingRatio: Double = defaultDampingRatio
        ) {
            self.angularFrequency = angularFrequency
            self.dampingRatio = dampingRatio

            assert(angularFrequency > 0)
            assert(dampingRatio > 0)
        }
    }
}
