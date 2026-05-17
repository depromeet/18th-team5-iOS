//
//  SolarTermRepositoryTests.swift
//  DataTests
//
//  Created by choijunios on 5/17/26.
//

@testable import Data
import Dependencies
import Domain
import Testing

@Suite
struct SolarTermRepositoryTests {
    @Test("모든 연도 파일 로드 성공", arguments: SolarTermYear.allCases)
    func fetchSolarTerms_파일_로드(year: SolarTermYear) async throws {
        // Given
        let sut = SolarTermRepositoryImpl.live()

        // When
        let result = try await sut.fetchSolarTerms(year)

        // Then
        #expect(result.count == 24)
    }

    @Test("각 절기의 날짜 범위가 유효", arguments: SolarTermYear.allCases)
    func fetchSolarTerms_날짜_범위_유효(year: SolarTermYear) async throws {
        // Given
        let sut = SolarTermRepositoryImpl.live()

        // When
        let result = try await sut.fetchSolarTerms(year)

        // Then
        let sorted = result.sorted(by: { $0.startDate < $1.startDate })
        for (index, info) in result.enumerated() {
            if index < sorted.count - 1 {
                let endDate = try #require(info.endDate)
                #expect(info.startDate < endDate)
            } else {
                #expect(info.endDate == nil)
            }
        }
    }

    @Test("연속된 절기의 endDate == 다음 절기의 startDate", arguments: SolarTermYear.allCases)
    func fetchSolarTerms_연속_절기_날짜_정합(year: SolarTermYear) async throws {
        // Given
        let sut = SolarTermRepositoryImpl.live()

        // When
        let result = try await sut.fetchSolarTerms(year)

        // Then
        let sorted = result.sorted(by: { $0.startDate < $1.startDate })
        for i in 0 ..< sorted.count {
            if i < sorted.count - 1 {
                #expect(result[i].endDate == result[i + 1].startDate)
            }
        }
    }
}
