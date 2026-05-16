//
//  SolarTerm.swift
//  Domain
//
//  Created by choijunios on 5/16/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public enum SolarTerm: Int, CaseIterable {
    case ipchun
    case usu
    case gyeongchip
    case chunbun
    case cheongmyeong
    case gogu

    case ibha
    case soman
    case mangjong
    case haji
    case soseo
    case daeseo

    case ibchu
    case cheoseo
    case baengno
    case chubun
    case hanro
    case sanggang

    case ibdong
    case soseol
    case daeseol
    case dongji
    case sohan
    case daehan
}

public protocol SolarLongitudeCalculator {
    func longitude(at date: Date) -> Double
}

private extension SolarTerm {
    private typealias C = Constants
    private enum Constants {
        static let ipchunLongitude: Double = 315
        static let degreesPerTerm: Double = 15
        static let count: Int = allCases.count
    }
}

public extension SolarTerm {
    init(longitude: Double) {
        let offset = (
            longitude.normalizedDegrees -
                C.ipchunLongitude + 360
        ).truncatingRemainder(dividingBy: 360)

        let index = Int(offset / C.degreesPerTerm) % C.count
        self = .init(rawValue: index) ?? .ipchun
    }

    init(
        from date: Date,
        calculator: SolarLongitudeCalculator = MeeusCalculator()
    ) {
        self = .init(longitude: calculator.longitude(at: date))
    }

    var longitudeRange: Range<Double> {
        let start = startLongitude
        let end = endLongitude
        return start > end ? start ..< 360 : start ..< end
    }

    var season: Season {
        switch rawValue {
        case 0 ... 5: .spring
        case 6 ... 11: .summer
        case 12 ... 17: .autumn
        case 18 ... 23: .winter
        default: .spring
        }
    }
}

private final class SimpleDictCache<Key: Hashable, Value>: @unchecked Sendable {
    private var dict: [Key: Value] = [:]
    private let storeLock = NSLock()
    subscript(_ key: Key) -> Value? {
        get { withLock { dict[key] } }
        set { withLock { dict[key] = newValue } }
    }

    private func withLock<T>(_ task: () -> T) -> T {
        defer { storeLock.unlock() }
        storeLock.lock()
        return task()
    }
}

private nonisolated let startLongitudeStore = SimpleDictCache<Int, Double>()

private extension SolarTerm {
    var startLongitude: Double {
        if let cached = startLongitudeStore[rawValue] {
            return cached
        }
        let longitude = (
            Constants.ipchunLongitude +
                Constants.degreesPerTerm *
                Double(rawValue)
        ).truncatingRemainder(dividingBy: 360)

        startLongitudeStore[rawValue] = longitude
        return longitude
    }

    var endLongitude: Double {
        let nextRawValue = (rawValue + 1) % C.count
        return (
            C.ipchunLongitude +
                C.degreesPerTerm *
                Double(nextRawValue)
        ).truncatingRemainder(dividingBy: 360)
    }
}

private extension Double {
    var normalizedDegrees: Double {
        var value = truncatingRemainder(dividingBy: 360)
        if value < 0 {
            value += 360
        }
        return value
    }
}
