//
//  MeeusCalculator.swift
//  Domain
//
//  Created by choijunios on 5/16/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public struct MeeusCalculator: SolarLongitudeCalculator {
    public init() {}
    public func longitude(at date: Date) -> Double {
        let jd = julianDay(from: date)
        let T = (jd - 2_451_545.0) / 36525.0

        let L0 =
            280.46646 +
            36000.76983 * T +
            0.0003032 * T * T

        let M =
            357.52911 +
            35999.05029 * T -
            0.0001537 * T * T

        let Mrad = degreesToRadians(M)

        let C =
            (1.914602 - 0.004817 * T - 0.000014 * T * T)
                * sin(Mrad)
                +
                (0.019993 - 0.000101 * T)
                * sin(2 * Mrad)
                +
                0.000289
                * sin(3 * Mrad)

        let trueLongitude = L0 + C

        let omega =
            125.04 - 1934.136 * T

        let apparentLongitude =
            trueLongitude
                - 0.00569
                - 0.00478 * sin(degreesToRadians(omega))

        return normalizedDegrees(apparentLongitude)
    }
}

extension MeeusCalculator {
    private func julianDay(from date: Date) -> Double {
        date.timeIntervalSince1970 / 86400.0 + 2_440_587.5
    }

    private func degreesToRadians(_ double: Double) -> Double {
        double * .pi / 180
    }

    private func radiansToDegrees(_ double: Double) -> Double {
        double * 180 / .pi
    }

    private func normalizedDegrees(_ double: Double) -> Double {
        var value = double.truncatingRemainder(dividingBy: 360)
        if value < 0 {
            value += 360
        }
        return value
    }
}
