import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct CalendarRepository: Sendable {
    public var fetchMonthRecords: @Sendable (_ year: Int, _ month: Int) async throws -> [CalendarRecord]
    public var fetchDayDetail: @Sendable (_ date: Date) async throws -> DayDetail
}

extension CalendarRepository: TestDependencyKey {
    public static let testValue = CalendarRepository()
}

public extension DependencyValues {
    var calendarRepository: CalendarRepository {
        get { self[CalendarRepository.self] }
        set { self[CalendarRepository.self] = newValue }
    }
}

public extension CalendarRepository {
    static let previewValue = CalendarRepository(
        fetchMonthRecords: { _, _ in [] },
        fetchDayDetail: { date in
            DayDetail(date: date, completions: [])
        }
    )
}
