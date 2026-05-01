import Foundation

public struct MissionCard: Equatable, Identifiable, Sendable {
    public let id: Int // completionId
    public let missionId: Int
    public let missionType: String
    public let imageURL: URL
    public let memo: String
    public let completedAt: Date

    public init(
        id: Int,
        missionId: Int,
        missionType: String,
        imageURL: URL,
        memo: String,
        completedAt: Date
    ) {
        self.id = id
        self.missionId = missionId
        self.missionType = missionType
        self.imageURL = imageURL
        self.memo = memo
        self.completedAt = completedAt
    }
}
