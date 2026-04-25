import ComposableArchitecture

@Reducer
struct ExampleFeature {
    @ObservableState
    struct State: Equatable {
        var items: [ExampleItem] = []
        var categoryGroups: [CategoryGroup] = []
        var selectedDetail: ExampleDetail?
        var isLoading = false
        var errorMessage: String?
    }

    enum Action {
        case onAppear
        case fetchItemsResponse(Result<[ExampleItem], Error>)
        case fetchGroupedItemsResponse(Result<[CategoryGroup], Error>)
        case itemTapped(id: Int)
        case fetchDetailResponse(Result<ExampleDetail, Error>)
        case createItemTapped(title: String, content: String, category: ExampleDetail.Category)
        case createItemResponse(Result<ExampleDetail, Error>)
        case dismissDetail
    }

    @Dependency(\.exampleRepository) var repository

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    let items = try await repository.fetchItems()
                    await send(.fetchItemsResponse(.success(items)))

                    let details = try await fetchAllDetails(for: items)
                    let categoryGroups = buildCategoryGroups(items: items, details: details)

                    await send(.fetchGroupedItemsResponse(.success(categoryGroups)))
                } catch: { error, send in
                    await send(.fetchGroupedItemsResponse(.failure(error)))
                }

            case let .fetchItemsResponse(.success(items)):
                state.items = items
                return .none

            case .fetchItemsResponse(.failure):
                return .none

            case let .fetchGroupedItemsResponse(.success(groups)):
                state.isLoading = false
                state.categoryGroups = groups
                return .none

            case let .fetchGroupedItemsResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none

            case let .itemTapped(id):
                return .run { send in
                    let detail = try await repository.fetchDetail(id: id)
                    await send(.fetchDetailResponse(.success(detail)))
                } catch: { error, send in
                    await send(.fetchDetailResponse(.failure(error)))
                }

            case let .fetchDetailResponse(.success(detail)):
                state.selectedDetail = detail
                return .none

            case .fetchDetailResponse(.failure):
                return .none

            case let .createItemTapped(title, content, category):
                return .run { send in
                    let detail = try await repository.createItem(
                        title: title, content: content, category: category
                    )
                    await send(.createItemResponse(.success(detail)))
                } catch: { error, send in
                    await send(.createItemResponse(.failure(error)))
                }

            case let .createItemResponse(.success(detail)):
                state.selectedDetail = detail
                return .none

            case .createItemResponse(.failure):
                return .none

            case .dismissDetail:
                state.selectedDetail = nil
                return .none
            }
        }
    }

    private func fetchAllDetails(for items: [ExampleItem]) async throws -> [ExampleDetail] {
        try await withThrowingTaskGroup(
            of: ExampleDetail.self,
            returning: [ExampleDetail].self
        ) { group in
            for item in items {
                group.addTask {
                    try await repository.fetchDetail(id: item.id)
                }
            }
            var results: [ExampleDetail] = []
            for try await detail in group {
                results.append(detail)
            }
            return results
        }
    }

    private func buildCategoryGroups(
        items: [ExampleItem],
        details: [ExampleDetail]
    ) -> [CategoryGroup] {
        let completionMap = Dictionary(
            uniqueKeysWithValues: items.map { ($0.id, $0.isCompleted) }
        )
        let grouped = Dictionary(grouping: details) { $0.category }
        let categoryOrder: [ExampleDetail.Category] = [.important, .general, .archived]

        return grouped.map { category, groupDetails in
            let sorted = groupDetails.sorted { $0.createdAt > $1.createdAt }
            let completedCount = groupDetails.filter { completionMap[$0.id] == true }.count
            let rate = groupDetails.isEmpty
                ? 0.0
                : Double(completedCount) / Double(groupDetails.count)
            return CategoryGroup(
                category: category,
                items: sorted,
                completionRate: rate
            )
        }
        .sorted { lhs, rhs in
            let lhsIndex = categoryOrder.firstIndex(of: lhs.category) ?? categoryOrder.count
            let rhsIndex = categoryOrder.firstIndex(of: rhs.category) ?? categoryOrder.count
            return lhsIndex < rhsIndex
        }
    }
}
