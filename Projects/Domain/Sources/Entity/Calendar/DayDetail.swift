import Foundation

public struct DayDetail: Equatable, Sendable {
    public let date: Date
    public let completions: [MissionCard]

    public init(date: Date, completions: [MissionCard]) {
        self.date = date
        self.completions = completions
    }
}
