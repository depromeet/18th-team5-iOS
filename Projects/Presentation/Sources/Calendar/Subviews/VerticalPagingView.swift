//
//  VerticalPagingView.swift
//  Presentation
//
//  Created by choijunios on 5/18/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI
import UIKit

public struct Page<Item: Equatable>: Identifiable, Equatable {
    public let id: Int
    let items: [Item]
}

public enum PagingDirection {
    case prepend, append
}

// MARK: - SwiftUI Wrapper

struct PagingTableView<Item: Identifiable & Equatable, Content: View>: UIViewRepresentable {
    var groups: [Page<Item>]
    @Binding var anchoredTermId: Item.ID?

    let anchorInset: CGFloat
    let onPagingRequest: (PagingDirection) -> Void
    let cellHeight: (Item) -> CGFloat
    let cellContent: (Item) -> Content

    init(
        groups: [Page<Item>],
        anchoredTermId: Binding<Item.ID?>,
        anchorInset: CGFloat,
        onPagingRequest: @escaping (PagingDirection) -> Void,
        cellHeight: @escaping (Item) -> CGFloat,
        @ViewBuilder cellContent: @escaping (Item) -> Content
    ) {
        self.groups = groups
        self._anchoredTermId = anchoredTermId
        self.anchorInset = anchorInset
        self.onPagingRequest = onPagingRequest
        self.cellHeight = cellHeight
        self.cellContent = cellContent
    }

    typealias UIKitView = PagingTableUIView<Item, Content>
    typealias Coordinator = PagingTableCoordinator<Item>

    func makeCoordinator() -> Coordinator { .init() }

    func makeUIView(context: Context) -> UIKitView {
        let view = UIKitView(anchorInset: anchorInset)
        view.delegate = context.coordinator
        configure(view, coordinator: context.coordinator)
        return view
    }

    func updateUIView(_ uiView: UIKitView, context: Context) {
        configure(uiView, coordinator: context.coordinator)
    }

    private func configure(_ uiView: UIKitView, coordinator: PagingTableCoordinator<Item>) {
        let centerBinding = $anchoredTermId
        let pagingHandler = onPagingRequest

        coordinator.onCenterItemChanged = { newCenterId in
            centerBinding.wrappedValue = newCenterId
        }
        coordinator.onPagingRequest = { direction in
            pagingHandler(direction)
        }

        uiView.cellBuilder = cellContent
        uiView.cellHeightProvider = cellHeight
        uiView.update(groups: groups, anchorId: anchoredTermId)
    }
}

// MARK: - Coordinator

final class PagingTableCoordinator<Item: Identifiable>: PagingTableUIViewDelegate {
    var onCenterItemChanged: ((Item.ID?) -> Void)?
    var onPagingRequest: ((PagingDirection) -> Void)?

    func pagingTableViewDidChangeAnchoredItem(id: Item.ID?) {
        onCenterItemChanged?(id)
    }

    func pagingTableViewDidRequestPaging(direction: PagingDirection) {
        onPagingRequest?(direction)
    }
}

// MARK: - PagingTableUIView Delegate

protocol PagingTableUIViewDelegate<Item>: AnyObject {
    associatedtype Item: Identifiable
    func pagingTableViewDidChangeAnchoredItem(id: Item.ID?)
    func pagingTableViewDidRequestPaging(direction: PagingDirection)
}

// MARK: - UIKit Paging Table View

final class PagingTableUIView<Item: Identifiable & Equatable, CellView: View>: UIView, UITableViewDataSource,
    UITableViewDelegate {
    // MARK: Public Configuration

    weak var delegate: (any PagingTableUIViewDelegate<Item>)?
    var cellBuilder: ((Item) -> CellView)?
    var cellHeightProvider: ((Item) -> CGFloat)?

    // MARK: Subviews

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let centerIndicator = UIView()
    private typealias Cell = HostingTableViewCell<CellView>
    private let cellReuseIdentifier = String(describing: Cell.self)

    // MARK: State

    private let anchorInset: CGFloat
    private var groups: [Page<Item>] = []
    private var prevAnchoredId: Item.ID?
    private var isAdjustingContentOffset: Bool = false
    private var isPagingPending: Bool = false

    // MARK: Init

    init(anchorInset: CGFloat) {
        self.anchorInset = anchorInset
        super.init(frame: .zero)
        setupView()
        setupTableView()
    }

    required init?(coder: NSCoder) { nil }

    func update(anchorId: Item.ID) {
        if let initialIndexPath = indexPath(for: anchorId) ?? middleIndexPath(in: groups) {
            tableView.scrollToRow(at: initialIndexPath, at: .middle, animated: false)
            tableView.contentOffset.y += anchorInset
        }
    }

    // MARK: Public Updates

    func update(groups newGroups: [Page<Item>], anchorId: Item.ID? = nil) {
        let oldGroupIds = groups.map(\.id)
        let newGroupIds = newGroups.map(\.id)
        guard oldGroupIds != newGroupIds else { return }

        let wasEmpty = groups.isEmpty

        // 위쪽 변화량 계산: prepend는 (+), front drop은 (-)
        let prependedGroupCount = countPrependedGroups(oldGroups: groups, newGroups: newGroups)
        let droppedGroupCount = countDroppedGroupsFromFront(oldGroups: groups, newGroups: newGroups)

        var offsetDelta: CGFloat = 0
        for groupOffset in 0 ..< prependedGroupCount {
            for item in newGroups[groupOffset].items {
                offsetDelta += heightOf(item: item)
            }
        }
        for groupOffset in 0 ..< droppedGroupCount {
            for item in groups[groupOffset].items {
                offsetDelta -= heightOf(item: item)
            }
        }

        groups = newGroups

        if offsetDelta != 0, tableView.bounds.height > 0 {
            let savedOffsetY = tableView.contentOffset.y
            isAdjustingContentOffset = true
            tableView.reloadData()
            tableView.layoutIfNeeded()
            tableView.contentOffset.y = savedOffsetY + offsetDelta
            isAdjustingContentOffset = false
        } else {
            tableView.reloadData()
        }

        if wasEmpty, let anchorId {
            if let indexPath = indexPath(for: anchorId) {
                tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                tableView.contentOffset.y += anchorInset
            }
        }

        isPagingPending = false
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        groups.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard groups.indices.contains(section) else { return 0 }
        return groups[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? Cell,
              let item = itemAt(indexPath: indexPath),
              let cellBuilder
        else { return UITableViewCell() }
        return cell.configure(cellBuilder(item))
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let item = itemAt(indexPath: indexPath) else { return 0 }
        return heightOf(item: item)
    }

    // MARK: - UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isAdjustingContentOffset,
              tableView.bounds.height > 0
        else { return }

        // 중앙 셀 변경 감지: 순수 함수 → 변화가 있을 때만 delegate 호출
        if let newAnchoredId = currentAnchoredItemId(),
           newAnchoredId != prevAnchoredId {
            prevAnchoredId = newAnchoredId
            delegate?.pagingTableViewDidChangeAnchoredItem(id: newAnchoredId)
        }

        // 페이징 필요성 감지: 순수 함수 → 결과가 있고 진행 중이 아닐 때만 delegate 호출
        if !isPagingPending, let direction = pagingDirectionNeeded() {
            isPagingPending = true
            delegate?.pagingTableViewDidRequestPaging(direction: direction)
        }
    }
}

// MARK: - Setup

private extension PagingTableUIView {
    func setupView() {
        backgroundColor = .clear
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(Cell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableView.estimatedRowHeight = 0
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.showsVerticalScrollIndicator = false

        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

// MARK: - Center & Paging Detection

private extension PagingTableUIView {
    func indexPath(for itemId: Item.ID) -> IndexPath? {
        for (groupIndex, group) in groups.enumerated() {
            if let itemIndex = group.items.firstIndex(where: { $0.id == itemId }) {
                return IndexPath(row: itemIndex, section: groupIndex)
            }
        }
        return nil
    }

    func heightOf(item: Item) -> CGFloat {
        cellHeightProvider?(item) ?? 0
    }

    func itemAt(indexPath: IndexPath) -> Item? {
        guard groups.indices.contains(indexPath.section),
              groups[indexPath.section].items.indices.contains(indexPath.row)
        else { return nil }
        return groups[indexPath.section].items[indexPath.row]
    }

    func middleIndexPath(in groups: [Page<Item>]) -> IndexPath? {
        let totalCount = groups.reduce(0) { $0 + $1.items.count }
        guard totalCount > 0 else { return nil }
        let target = totalCount / 2

        var accumulated = 0
        for (section, group) in groups.enumerated() {
            if target < accumulated + group.items.count {
                return IndexPath(row: target - accumulated, section: section)
            }
            accumulated += group.items.count
        }
        return nil
    }

    /// 현재 뷰포트 앵커에 위치한 셀의 ID를 반환합니다. 부수효과 없음.
    func currentAnchoredItemId() -> Item.ID? {
        let anchorY = tableView.contentOffset.y - anchorInset
        let anchorPoint = CGPoint(x: tableView.bounds.midX, y: anchorY)
        guard let indexPath = tableView.indexPathForRow(at: anchorPoint),
              let item = itemAt(indexPath: indexPath)
        else { return nil }
        return item.id
    }

    /// 현재 스크롤 상태가 페이징이 필요한 경계인지 판단해 방향을 반환합니다. 필요 없으면 nil. 부수효과 없음.
    func pagingDirectionNeeded() -> PagingDirection? {
        let offsetY = tableView.contentOffset.y
        let maxOffsetY = max(tableView.contentSize.height - tableView.bounds.height, 0)
        guard maxOffsetY > 0 else { return nil }
        if offsetY <= 0 { return .prepend }
        if offsetY >= maxOffsetY { return .append }
        return nil
    }

    /// groups가 prepend 형태로 갱신되었는지 확인하고, 앞쪽에 추가된 그룹 개수를 반환합니다.
    /// prepend 형태가 아니면 0을 반환합니다.
    func countPrependedGroups(
        oldGroups: [Page<Item>],
        newGroups: [Page<Item>]
    ) -> Int {
        guard !oldGroups.isEmpty, !newGroups.isEmpty else { return 0 }
        guard let oldFirstId = oldGroups.first?.id,
              let prependedCount = newGroups.firstIndex(where: { $0.id == oldFirstId }),
              prependedCount > 0
        else { return 0 }

        let overlapCount = min(oldGroups.count, newGroups.count - prependedCount)
        for offset in 0 ..< overlapCount where newGroups[prependedCount + offset].id != oldGroups[offset].id {
            return 0
        }
        return prependedCount
    }

    /// groups가 앞에서부터 drop 형태로 갱신되었는지 확인하고, 제거된 그룹 개수를 반환합니다.
    /// front drop 형태가 아니면 0을 반환합니다.
    func countDroppedGroupsFromFront(
        oldGroups: [Page<Item>],
        newGroups: [Page<Item>]
    ) -> Int {
        guard !oldGroups.isEmpty, !newGroups.isEmpty else { return 0 }
        guard let newFirstId = newGroups.first?.id,
              let droppedCount = oldGroups.firstIndex(where: { $0.id == newFirstId }),
              droppedCount > 0
        else { return 0 }

        let overlapCount = min(newGroups.count, oldGroups.count - droppedCount)
        for offset in 0 ..< overlapCount where oldGroups[droppedCount + offset].id != newGroups[offset].id {
            return 0
        }
        return droppedCount
    }
}

// MARK: - Hosting Table View Cell

final class HostingTableViewCell<RootView: View>: UITableViewCell {
    private var hostingController: UIHostingController<RootView>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupAppearance()
    }

    required init?(coder: NSCoder) { nil }

    @discardableResult
    func configure(_ rootView: RootView) -> Self {
        if let hostingController {
            hostingController.rootView = rootView
        } else {
            let controller = UIHostingController(rootView: rootView)
            controller.view.backgroundColor = .clear
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(controller.view)
            NSLayoutConstraint.activate([
                controller.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                controller.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                controller.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                controller.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
            hostingController = controller
        }
        return self
    }
}

private extension HostingTableViewCell {
    func setupAppearance() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
}

// MARK: - Preview

#if DEBUG
import Combine

public struct PagingCellModel: Identifiable, Equatable {
    public let id: UUID = .init()
    let value: Int
    let height: CGFloat
    let backgroundColor: Color
}

@MainActor
final class PagingTableViewModel: ObservableObject {
    let maxBatchCount: Int = 2

    private var groupId = 0

    @Published var groups: [Page<PagingCellModel>] = []
    @Published var anchoredTermId: PagingCellModel.ID?

    init() {
        groups = [makeGroup()]
    }

    func handlePagingRequest(_ direction: PagingDirection) {
        switch direction {
        case .prepend:
            var updated = [makeGroup()] + groups
            // 배치가 maxBatchCount를 초과하면 반대쪽 끝(마지막 배치)을 제거
            if updated.count > maxBatchCount {
                updated.removeLast()
            }
            groups = updated
        case .append:
            var updated = groups + [makeGroup()]
            if updated.count > maxBatchCount {
                updated.removeFirst()
            }
            groups = updated
        }
    }

    private func makeGroup() -> Page<PagingCellModel> {
        let backgroundColor = Color(
            red: .random(in: 0.3 ... 0.9),
            green: .random(in: 0.3 ... 0.9),
            blue: .random(in: 0.3 ... 0.9)
        )
        let items = (1 ... 12).map { value in
            PagingCellModel(
                value: value,
                height: CGFloat((60 ... 160).randomElement()!),
                backgroundColor: backgroundColor
            )
        }
        defer { groupId += 1 }
        return Page(
            id: groupId,
            items: items
        )
    }
}

private struct PagingTablePreviewWrapper: View {
    @StateObject private var viewModel = PagingTableViewModel()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Anchor: ")
                if let centerId = viewModel.anchoredTermId,
                   let item = viewModel.groups.flatMap(\.items).first(where: { $0.id == centerId }) {
                    Text("\(item.value)")
                        .fontWeight(.bold)
                } else {
                    Text("-")
                }
                Spacer()
                Text("group count: \(viewModel.groups.count)")
            }
            .padding()

            PagingTableView(
                groups: viewModel.groups,
                anchoredTermId: $viewModel.anchoredTermId,
                anchorInset: 10,
                onPagingRequest: viewModel.handlePagingRequest,
                cellHeight: { $0.height }
            ) { item in
                ZStack {
                    item.backgroundColor
                    Text("\(item.value)")
                        .font(.title)
                        .foregroundStyle(.black)
                }
                .border(.black)
            }
        }
    }
}

#Preview {
    PagingTablePreviewWrapper()
}
#endif
