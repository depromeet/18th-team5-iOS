//
//  SolarTermIntro.swift
//  Domain
//
//  Created by 송민교 on 5/18/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Foundation

public struct SolarTermIntro: Equatable, Hashable {
    public let term: SolarTerm
    public let introTitle: String
    public let introSubtitle: String
    public let title: String
    public let meaning: String
    public let characteristic: String
    public let contentTitle: String
    public let contentBody: String
    public let contents: [SolarTermIntroContent]

    public init(
        term: SolarTerm,
        introTitle: String,
        introSubtitle: String,
        title: String,
        meaning: String,
        characteristic: String,
        contentTitle: String,
        contentBody: String,
        contents: [SolarTermIntroContent]
    ) {
        self.term = term
        self.introTitle = introTitle
        self.introSubtitle = introSubtitle
        self.title = title
        self.meaning = meaning
        self.characteristic = characteristic
        self.contentTitle = contentTitle
        self.contentBody = contentBody
        self.contents = contents
    }
}

public extension SolarTermIntro {
    static let mock = SolarTermIntro(
        term: .ibha,
        introTitle: "입하,\n여름이 일어서는 시간",
        introSubtitle: "여름, 첫 번째 제철",
        title: "여름이 일어서는 시간,\n24절기 중 7번째 절기",
        meaning: "여름이 시작됨을 알리는 절기에요",
        characteristic: "신록이 우거지고 개구리 울음소리가 들리기 시작하며 농작물이 자라기 시작하는 시기예요",
        contentTitle: "입하,\n이제 진짜 외투를 넣을 시간이에요",
        contentBody: "아침저녁으로 쌀쌀한데, 벌써 여름인가 싶으시죠? 5월 5일부터 시작되는 입하는 여름이 문을 열고 들어오는 첫날입니다. Peaktime이 이번 입하를 맞아, 일상 속 해상도를 높여줄 '여름 시작 가이드'를 준비했습니다.",
        contents: [
            SolarTermIntroContent(
                id: "content_01",
                title: "피크타임이 추천하는 입하의 첫 활동",
                subtitle: "투명함으로 바꾸는 기분, 유리잔 바꿔주기",
                imageURL: "https://picsum.photos/seed/ibha_01/400/300",
                body: "무거운 세라믹 머그컵 대신, 찬장에 넣어두었던 유리잔을 꺼내는 것부터 시작하세요. 얼음을 가득 채웠을 때 컵 겉면에 맺히는 물방울은 시원한 휴식을 줍니다."
            ),
            SolarTermIntroContent(
                id: "content_02",
                title: "제철을 잘 챙기는\n두번째 방법, 제철음식 챙겨먹기",
                subtitle: "이번 주 식탁의 주인공, '취나물'을 소개해요",
                imageURL: "https://picsum.photos/seed/ibha_02/400/300",
                body: "입하 즈음의 시장에서 꼭 찾아야 할 건 취나물입니다. 지금이 일 년 중 가장 연하면서도 향이 강한 시기거든요. 잎이 너무 크고 억센 것보다는 연둣빛이 감도는 어린잎을 골라보세요!"
            )
        ]
    )

    static let mockList: [SolarTermIntro] = [
        .mock,
        SolarTermIntro(
            term: .soman,
            introTitle: "소만,\n만물이 자라나는 시간",
            introSubtitle: "여름, 두 번째 제철",
            title: "만물이 자라나는 시간,\n24절기 중 8번째 절기",
            meaning: "햇볕이 풍성해지고 만물이 점차 자라서 가득 찬다는 뜻의 절기예요",
            characteristic: "햇볕이 풍성해지고 만물이 점차 자라서 가득 찬다는 뜻의 절기예요",
            contentTitle: "소만,\n초록이 짙어지는 계절의 문턱",
            contentBody: "본격적인 농사가 시작되는 시기입니다.",
            contents: []
        ),
        SolarTermIntro(
            term: .mangjong,
            introTitle: "망종,\n씨 뿌리는 시간",
            introSubtitle: "여름, 세 번째 제철",
            title: "씨 뿌리는 시간,\n24절기 중 9번째 절기",
            meaning: "보리 베기와 모내기를 하는 절기예요",
            characteristic: "보리 베기와 모내기를 하는 절기예요",
            contentTitle: "망종,\n곡식의 씨를 뿌리는 시간",
            contentBody: "곡식의 종자를 뿌려야 할 적당한 시기라는 뜻입니다.",
            contents: []
        ),
        SolarTermIntro(
            term: .haji,
            introTitle: "하지,\n해가 가장 긴 시간",
            introSubtitle: "여름, 네 번째 제철",
            title: "해가 가장 긴 시간,\n24절기 중 10번째 절기",
            meaning: "일 년 중 낮이 가장 긴 날이에요",
            characteristic: "일 년 중 낮이 가장 긴 날이에요",
            contentTitle: "하지,\n태양이 가장 높이 뜨는 날",
            contentBody: "태양이 가장 높이 뜨고 낮이 가장 긴 날입니다.",
            contents: []
        )
    ]
}
