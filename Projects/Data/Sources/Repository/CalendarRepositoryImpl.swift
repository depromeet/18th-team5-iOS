import Dependencies
import Domain
import Foundation

extension CalendarRepository: @retroactive DependencyKey {
    public static let liveValue: CalendarRepository = CalendarRepositoryImpl.live()
}

public enum CalendarRepositoryImpl {
    public static func live() -> CalendarRepository {
        CalendarRepository(
            fetchMonthRecords: { year, month in
                @Dependency(\.networkClient) var client
                let response: CalendarMonthResponseDTO = try await client.request(
                    CalendarEndpoint.fetchMonthRecords(year: year, month: month)
                )
                return response.data.records.compactMap { $0.toDomain() }
            },
            fetchDayDetail: { date in
                @Dependency(\.networkClient) var client
                let response: DayDetailResponseWrapperDTO = try await client.request(
                    CalendarEndpoint.fetchDayDetail(date: date)
                )
                return response.data.toDomain()
            }
        )
    }
}

// MARK: - Domain Mapping

private extension CalendarRecordResponseDTO {
    func toDomain() -> CalendarRecord? {
        guard hasRecord, let urlString = thumbnailImageUrl, let url = URL(string: urlString) else {
            return nil
        }
        let parsedDate = DateFormatter.yyyyMMdd.date(from: date) ?? Date()
        return CalendarRecord(dateString: date, date: parsedDate, imageURL: url)
    }
}

private extension DayDetailDataDTO {
    func toDomain() -> DayDetail {
        let parsedDate = DateFormatter.yyyyMMdd.date(from: date) ?? Date()
        return DayDetail(date: parsedDate)
    }
}

private extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
}
