//
//  SpringInterpolation+Parameters.swift
//  SpringInterpolation
//
//  Created by QAQ on 2023/12/16.
//

import Foundation

public extension SpringInterpolation {
    struct Parameters {
        public let deltaTime: Double
        public let posPosCoef, posVelCoef: Double
        public let velPosCoef, velVelCoef: Double

        public init(
            deltaTime: Double,
            posPosCoef: Double,
            posVelCoef: Double,
            velPosCoef: Double,
            velVelCoef: Double
        ) {
            self.deltaTime = deltaTime
            self.posPosCoef = posPosCoef
            self.posVelCoef = posVelCoef
            self.velPosCoef = velPosCoef
            self.velVelCoef = velVelCoef
        }
    }
}
