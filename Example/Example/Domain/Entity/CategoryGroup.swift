import Foundation

struct CategoryGroup: Equatable, Identifiable {
    var id: ExampleDetail.Category {
        category
    }

    let category: ExampleDetail.Category
    let items: [ExampleDetail]
    let completionRate: Double
}
