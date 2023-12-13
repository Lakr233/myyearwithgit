//
//  SpringInterpolation+Context.swift
//  SpringInterpolation
//
//  Created by QAQ on 2023/12/3.
//

import Foundation

public extension SpringInterpolation {
    struct Context {
        public let posPosCoef, posVelCoef: Double
        public let velPosCoef, velVelCoef: Double

        public var currentPos: Double
        public var currentVel: Double
        public var targetPos: Double

        public init(
            posPosCoef: Double,
            posVelCoef: Double,
            velPosCoef: Double,
            velVelCoef: Double,
            currentPos: Double = 0,
            currentVel: Double = 0,
            targetPos: Double = 0
        ) {
            self.posPosCoef = posPosCoef
            self.posVelCoef = posVelCoef
            self.velPosCoef = velPosCoef
            self.velVelCoef = velVelCoef
            self.currentPos = currentPos
            self.currentVel = currentVel
            self.targetPos = targetPos
        }
    }
}

public extension SpringInterpolation.Configuration {
    func generateContext() -> SpringInterpolation.Context {
        if angularFrequency < epsilon {
            return .init(posPosCoef: 1, posVelCoef: 0, velPosCoef: 0, velVelCoef: 1)
        }

        if dampingRatio > 1.0 + epsilon {
            let za = -angularFrequency * dampingRatio
            let zb = angularFrequency * sqrt(dampingRatio * dampingRatio - 1.0)
            let z1 = za - zb
            let z2 = za + zb

            let e1 = exp(z1 * deltaTime)
            let e2 = exp(z2 * deltaTime)
            let invTwoZb = 1.0 / (2.0 * zb)

            let e1_Over_TwoZb = e1 * invTwoZb
            let e2_Over_TwoZb = e2 * invTwoZb
            let z1e1_Over_TwoZb = z1 * e1_Over_TwoZb
            let z2e2_Over_TwoZb = z2 * e2_Over_TwoZb

            let posPosCoef = e1_Over_TwoZb * z2 - z2e2_Over_TwoZb + e2
            let posVelCoef = -e1_Over_TwoZb + e2_Over_TwoZb

            let velPosCoef = (z1e1_Over_TwoZb - z2e2_Over_TwoZb + e2) * z2
            let velVelCoef = -z1e1_Over_TwoZb + z2e2_Over_TwoZb

            return .init(posPosCoef: posPosCoef, posVelCoef: posVelCoef, velPosCoef: velPosCoef, velVelCoef: velVelCoef)
        }

        if dampingRatio < 1.0 - epsilon {
            let omegaZeta = angularFrequency * dampingRatio
            let alpha = angularFrequency * sqrt(1.0 - dampingRatio * dampingRatio)

            let expTerm = exp(-omegaZeta * deltaTime)
            let cosTerm = cos(alpha * deltaTime)
            let sinTerm = sin(alpha * deltaTime)

            let invAlpha = 1.0 / alpha

            let expSin = expTerm * sinTerm
            let expCos = expTerm * cosTerm
            let expOmegaZetaSin_Over_Alpha = expTerm * omegaZeta * sinTerm * invAlpha

            let posPosCoef = expCos + expOmegaZetaSin_Over_Alpha
            let posVelCoef = expSin * invAlpha

            let velPosCoef = -expSin * alpha - omegaZeta * expOmegaZetaSin_Over_Alpha
            let velVelCoef = expCos - expOmegaZetaSin_Over_Alpha

            return .init(posPosCoef: posPosCoef, posVelCoef: posVelCoef, velPosCoef: velPosCoef, velVelCoef: velVelCoef)
        }

        let expTerm = exp(-angularFrequency * deltaTime)
        let timeExp = deltaTime * expTerm
        let timeExpFreq = timeExp * angularFrequency

        let posPosCoef = timeExpFreq + expTerm
        let posVelCoef = timeExp

        let velPosCoef = -angularFrequency * timeExpFreq
        let velVelCoef = -timeExpFreq + expTerm
        return .init(posPosCoef: posPosCoef, posVelCoef: posVelCoef, velPosCoef: velPosCoef, velVelCoef: velVelCoef)
    }
}
