import Foundation

struct ExampleDetail: Equatable {
    let id: Int
    let title: String
    let content: String
    let category: Category
    let tags: [String]
    let imageURL: URL?
    let createdAt: Date
}

extension ExampleDetail {
    enum Category: String, Equatable, Hashable {
        case general
        case important
        case archived
    }
}
