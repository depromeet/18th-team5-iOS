//
//  SolarTerm.swift
//  Domain
//
//  Created by choijunios on 5/16/26.
//  Copyright © 2026 Orange. All rights reserved.
//

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
