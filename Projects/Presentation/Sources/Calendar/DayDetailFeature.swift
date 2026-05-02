import ComposableArchitecture
import Domain
import Foundation

@Reducer
public struct DayDetailFeature {
    @ObservableState
    public struct State: Equatable {
        var selectedDate: Date
        var weekDays: [Date]
        var weekRecords: [DateComponents: CalendarRecord] // CalendarFeature에서 주입
        var completions: [MissionCard] = []
        var currentCardIndex: Int = 0
        var isLoading: Bool = false

        public init(selectedDate: Date, weekRecords: [DateComponents: CalendarRecord]) {
            self.selectedDate = selectedDate
            self.weekRecords = weekRecords
            self.weekDays = Self.weekDays(containing: selectedDate)
        }

        static func weekDays(containing date: Date) -> [Date] {
            var calendar = Calendar.current
            calendar.firstWeekday = 2 // 월요일 시작
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else { return [] }
            return (0 ..< 7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekInterval.start) }
        }

        mutating func moveWeek(by value: Int) -> Date? {
            guard let newDate = Calendar.current.date(byAdding: .weekOfYear, value: value, to: selectedDate)
            else { return nil }
            selectedDate = newDate
            weekDays = Self.weekDays(containing: newDate)
            return newDate
        }
    }

    public enum Action {
        case onAppear
        case previousWeekTap
        case nextWeekTap
        case saveImageTap
        case saveLinkTap
        case cardSwipe
        case completionsLoad(Result<DayDetail, Error>)
        case dateTap(Date)
        case delegate(Delegate)

        public enum Delegate {
            case dismiss
        }
    }

    @Dependency(\.calendarRepository) var calendarRepository

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return fetchCompletions(for: state.selectedDate)

            case .previousWeekTap:
                guard let newDate = state.moveWeek(by: -1) else { return .none }
                state.isLoading = true
                return fetchCompletions(for: newDate)

            case .nextWeekTap:
                guard let newDate = state.moveWeek(by: 1) else { return .none }
                state.isLoading = true
                return fetchCompletions(for: newDate)

            case .saveImageTap:
                // TODO: 이미지 저장 구현 - 민교
                return .none

            case .saveLinkTap:
                // TODO: 링크 저장 구현 - 민교
                return .none

            case .cardSwipe:
                guard !state.completions.isEmpty else { return .none }
                // 마지막 카드 넘기면 첫 카드로 순환
                state.currentCardIndex = (state.currentCardIndex + 1) % state.completions.count
                return .none

            case let .completionsLoad(.success(detail)):
                state.isLoading = false
                state.completions = detail.completions
                state.currentCardIndex = 0
                return .none

            case .completionsLoad(.failure):
                state.isLoading = false
                return .none

            case let .dateTap(date):
                state.isLoading = true
                state.selectedDate = date
                return fetchCompletions(for: date)

            case .delegate:
                return .none
            }
        }
    }

    private func fetchCompletions(for date: Date) -> Effect<Action> {
        .run { send in
            await send(.completionsLoad(
                Result { try await calendarRepository.fetchDayDetail(date) }
            ))
        }
    }
}
