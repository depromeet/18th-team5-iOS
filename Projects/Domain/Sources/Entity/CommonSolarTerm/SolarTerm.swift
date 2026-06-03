//
//  SolarTerm.swift
//  Domain
//
//  Created by choijunios on 5/16/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Core

public enum SolarTerm: String, CaseIterable {
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

    public var koreanName: String {
        switch self {
        case .ipchun: "입춘"
        case .usu: "우수"
        case .gyeongchip: "경칩"
        case .chunbun: "춘분"
        case .cheongmyeong: "청명"
        case .gogu: "곡우"
        case .ibha: "입하"
        case .soman: "소만"
        case .mangjong: "망종"
        case .haji: "하지"
        case .soseo: "소서"
        case .daeseo: "대서"
        case .ibchu: "입추"
        case .cheoseo: "처서"
        case .baengno: "백로"
        case .chubun: "추분"
        case .hanro: "한로"
        case .sanggang: "상강"
        case .ibdong: "입동"
        case .soseol: "소설"
        case .daeseol: "대설"
        case .dongji: "동지"
        case .sohan: "소한"
        case .daehan: "대한"
        }
    }

    public var season: Season {
        switch self {
        case .ipchun, .usu, .gyeongchip, .chunbun, .cheongmyeong, .gogu:
            .spring
        case .ibha, .soman, .mangjong, .haji, .soseo, .daeseo:
            .summer
        case .ibchu, .cheoseo, .baengno, .chubun, .hanro, .sanggang:
            .autumn
        case .ibdong, .soseol, .daeseol, .dongji, .sohan, .daehan:
            .winter
        }
    }
}

public extension SolarTerm {
    var yearOrder: Int {
        switch self {
        case .sohan: 0
        case .daehan: 1
        case .ipchun: 2
        case .usu: 3
        case .gyeongchip: 4
        case .chunbun: 5
        case .cheongmyeong: 6
        case .gogu: 7
        case .ibha: 8
        case .soman: 9
        case .mangjong: 10
        case .haji: 11
        case .soseo: 12
        case .daeseo: 13
        case .ibchu: 14
        case .cheoseo: 15
        case .baengno: 16
        case .chubun: 17
        case .hanro: 18
        case .sanggang: 19
        case .ibdong: 20
        case .soseol: 21
        case .daeseol: 22
        case .dongji: 23
        }
    }

    static var yearList: [SolarTerm] {
        Array(allCases)
            .sorted(by: { $0.yearOrder < $1.yearOrder })
    }

    static var firstStartTermInYear: Self {
        yearList.first ?? .sohan
    }

    static var lastStartTermInYear: Self {
        yearList.last ?? .dongji
    }

    func nextTermInYear() -> Self? {
        let list = Self.yearList
        guard let index = list.firstIndex(of: self)
        else { return nil }

        let nextIndex = index + 1
        return list[safe: nextIndex]
    }

    func prevTermInYear() -> Self? {
        let list = Self.yearList
        guard let index = list.firstIndex(of: self)
        else { return nil }

        let prevIndex = index - 1
        return list[safe: prevIndex]
    }
}
