//
//  CalendarRepsitory+Mock.swift
//  Presentation
//
//  Created by 송민교 on 5/1/26.
//  Copyright © 2026 Orange. All rights reserved.
//
import Domain
import Foundation

extension CalendarRepository {
    static let mock = CalendarRepository(
        fetchMonthRecords: { _, _ in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let base = Calendar.current.date(
                from: Calendar.current.dateComponents([.year, .month], from: Date())
            ) ?? Date()
            return (1 ... 15).compactMap { day -> CalendarRecord? in
                guard day % 2 != 0,
                      let date = Calendar.current.date(byAdding: .day, value: day - 1, to: base),
                      let url = URL(string: "https://picsum.photos/seed/\(day)/200")
                else { return nil }
                return CalendarRecord(
                    dateString: formatter.string(from: date),
                    date: date,
                    imageURL: url
                )
            }
        },
        fetchDayDetail: { date in
            DayDetail(
                date: date,
                completions: [
                    MissionCard(
                        id: 1001,
                        missionId: 101,
                        missionType: "DAILY",
                        imageURL: URL(string: "https://picsum.photos/seed/42/400/300")!,
                        memo: "오늘 공원에서 찍은 사진이에요.",
                        completedAt: date
                    ),
                    MissionCard(
                        id: 1002,
                        missionId: 102,
                        missionType: "WEEKLY",
                        imageURL: URL(string: "https://picsum.photos/seed/77/400/300")!,
                        memo: "친구랑 같이 카페 다녀왔어요.",
                        completedAt: date
                    ),
                    MissionCard(
                        id: 1003,
                        missionId: 103,
                        missionType: "DAILY",
                        imageURL: URL(string: "https://picsum.photos/seed/13/400/300")!,
                        memo: "저녁 노을이 예뻤던 하루.",
                        completedAt: date
                    ),
                    MissionCard(
                        id: 1004,
                        missionId: 104,
                        missionType: "MONTHLY",
                        imageURL: URL(string: "https://picsum.photos/seed/99/400/300")!,
                        memo: "드디어 첫 번째 달 미션 완료!",
                        completedAt: date
                    )
                ]
            )
        }
    )
}
