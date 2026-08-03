//
//  SolarTerm+CardImage.swift
//  Presentation
//
//  Created by 송민교 on 6/8/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import Domain
import SwiftUI

extension SolarTerm {
    var cardImage: Image {
        switch self {
        case .ipchun: .imgIpchunHomeCard
        case .usu: .imgUsuHomeCard
        case .gyeongchip: .imgGyeongchipHomeCard
        case .chunbun: .imgChunbunHomeCard
        case .cheongmyeong: .imgCheongmyeongHomeCard
        case .gogu: .imgGoguHomeCard
        case .ibha: .imgIbhaHomeCard
        case .soman: .imgSomanHomeCard
        case .mangjong: .imgMangjongHomeCard
        case .haji: .imgHajiHomeCard
        case .soseo: .imgSoseoHomeCard
        case .daeseo: .imgDaeseoHomeCard
        case .ibchu: .imgIbchuHomeCard
        case .cheoseo: .imgCheoseoHomeCard
        case .baengno: .imgBaengnoHomeCard
        case .chubun: .imgChubunHomeCard
        case .hanro: .imgHanroHomeCard
        case .sanggang: .imgSanggangHomeCard
        case .ibdong: .imgIbdongHomeCard
        case .soseol: .imgSoseolHomeCard
        case .daeseol: .imgDaeseolHomeCard
        case .dongji: .imgDongjiHomeCard
        case .sohan: .imgSohanHomeCard
        case .daehan: .imgDaehanHomeCard
        }
    }

    var solarTermCardImage: Image {
        switch self {
        case .ipchun: .imgIpchunSolarTermCard
        case .usu: .imgUsuSolarTermCard
        case .gyeongchip: .imgGyeongchipSolarTermCard
        case .chunbun: .imgChunbunSolarTermCard
        case .cheongmyeong: .imgCheongmyeongSolarTermCard
        case .gogu: .imgGoguSolarTermCard
        case .ibha: .imgIbhaSolarTermCard
        case .soman: .imgSomanSolarTermCard
        case .mangjong: .imgMangjongSolarTermCard
        case .haji: .imgHajiSolarTermCard
        case .soseo: .imgSoseoSolarTermCard
        case .daeseo: .imgDaeseoSolarTermCard
        case .ibchu: .imgIbchuSolarTermCard
        case .cheoseo: .imgCheoseoSolarTermCard
        case .baengno: .imgBaengnoSolarTermCard
        case .chubun: .imgChubunSolarTermCard
        case .hanro: .imgHanroSolarTermCard
        case .sanggang: .imgSanggangSolarTermCard
        case .ibdong: .imgIbdongSolarTermCard
        case .soseol: .imgSoseolSolarTermCard
        case .daeseol: .imgDaeseolSolarTermCard
        case .dongji: .imgDongjiSolarTermCard
        case .sohan: .imgSohanSolarTermCard
        case .daehan: .imgDaehanSolarTermCard
        }
    }
}
