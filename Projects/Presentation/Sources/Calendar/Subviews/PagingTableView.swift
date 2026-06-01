//
//  PagingTableView.swift
//  Presentation
//
//  Created by choijunios on 5/18/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Combine
import Core
import SwiftUI
import UIKit

public struct Page<Item: Equatable>: Identifiable, Equatable {
    public let id: Int
    public var items: [Item]
}

public enum PageEndDirection {
    case top, bottom
}

public struct AnchorRequest<Item: Identifiable & Equatable>: Equatable {
    public let requestId = UUID()
    public let itemId: Item.ID
    public let inset: CGFloat?
    public let animated: Bool
}

public struct PagingTableViewState<Item: Identifiable & Equatable>: Equatable {
    public var anchorRequest: AnchorRequest<Item>?
    public var pages: [Page<Item>]
}

// MARK: - UIKit Paging Table View

final class PagingTableView<Item: Identifiable & Equatable>: UIView, UITableViewDataSource,
    BridgingUIView,
    UITableViewDelegate {
    struct Arguments {
        let defaultAnchorInset: CGFloat
        let cellBuilder: (Item) -> AnyView
        let cellHeightProvider: (Item) -> CGFloat
    }

    private let arguments: Arguments

    enum Action {
        case anchoredItemChanged(id: Item.ID)
        case reachedToEnd(direction: PageEndDirection)
    }

    var action: AnyPublisher<Action, Never> {
        _action.eraseToAnyPublisher()
    }

    private let _action: PassthroughSubject<Action, Never> = .init()
    private var store: Set<AnyCancellable> = []

    // MARK: Subviews

    private let tableView = UITableView(frame: .zero, style: .plain)
    private typealias Cell = HostingTableViewCell<AnyView>

    // MARK: Internal state

    private var pages: [Page<Item>] = []
    private var prevAnchoredId: Item.ID?
    private var isAdjustingContentOffset: Bool = false
    private var isPageUpdating: Bool = false

    init(arguments: Arguments) {
        self.arguments = arguments
        super.init(frame: .zero)
        setupView()
        setupTableView()
    }

    required init?(coder: NSCoder) {
        nil
    }

    typealias State = PagingTableViewState<Item>

    func bind(_ context: AnyPublisher<UpdateContext<State>, Never>) {
        let state = context.map(\.state)

        state
            .map(\.pages)
            .removeDuplicates()
            .sink { [weak self] pages in
                self?.update(pages: pages)
            }
            .store(in: &store)

        state
            .compactMap(\.anchorRequest)
            .removeDuplicates()
            .sink { [weak self] request in
                self?.update(request: request)
            }
            .store(in: &store)
    }

    // MARK: - UITableViewDataSource

    func numberOfSections(in tableView: UITableView) -> Int {
        pages.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard pages.indices.contains(section) else { return 0 }
        return pages[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: Cell.self),
            for: indexPath
        ) as? Cell,
            let item = itemAt(indexPath: indexPath)
        else { return UITableViewCell() }
        return cell.configure(arguments.cellBuilder(item))
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let item = itemAt(indexPath: indexPath) else { return 0 }
        return arguments.cellHeightProvider(item)
    }

    // MARK: - UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isAdjustingContentOffset,
              tableView.bounds.height > 0
        else { return }

        // 앵커에 걸린 셀 변경 감지: 순수 함수 → 변화가 있을 때만 action 방출
        if let newAnchoredId = currentAnchoredItemId(),
           newAnchoredId != prevAnchoredId {
            prevAnchoredId = newAnchoredId
            _action.send(.anchoredItemChanged(id: newAnchoredId))
        }

        // 페이징 필요성 감지: 순수 함수 → 결과가 있고 진행 중이 아닐 때만 action 방출
        if !isPageUpdating, let direction = pagingDirectionNeeded() {
            _action.send(.reachedToEnd(direction: direction))
        }
    }
}

// MARK: Setup views

private extension PagingTableView {
    func setupView() {
        backgroundColor = .clear
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(Cell.self, forCellReuseIdentifier: String(describing: Cell.self))
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

// MARK: Updates

private extension PagingTableView {
    func update(pages newPages: [Page<Item>]) {
        defer { isPageUpdating = false }
        isPageUpdating = true

        let oldPages = pages
        pages = newPages

        let hasStructuralChanges = (oldPages.map(\.id) != newPages.map(\.id))
        if hasStructuralChanges {
            updateTableStructure(oldPages, newPages)
        } else {
            updateItems(oldPages, newPages)
        }
    }

    func updateTableStructure(_ oldPages: [Page<Item>], _ newPages: [Page<Item>]) {
        var offsetDelta: CGFloat = 0
        for groupOffset in 0 ..< prependedCount(oldPages, newPages) {
            for item in newPages[groupOffset].items {
                offsetDelta += arguments.cellHeightProvider(item)
            }
        }
        for groupOffset in 0 ..< droppedCount(oldPages, newPages) {
            for item in oldPages[groupOffset].items {
                offsetDelta -= arguments.cellHeightProvider(item)
            }
        }

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
    }

    func updateItems(_ oldPages: [Page<Item>], _ newPages: [Page<Item>]) {
        guard oldPages.count == newPages.count else { return }

        var diffIndexPaths: [IndexPath] = []
        for pageIndex in 0 ..< oldPages.count {
            guard let oldPage = oldPages[safe: pageIndex],
                  let newPage = newPages[safe: pageIndex],
                  oldPage.items.count == newPage.items.count
            else { continue }

            let indexPaths = (0 ..< oldPage.items.count).filter { itemIndex in
                guard let oldItem = oldPage.items[safe: itemIndex],
                      let newItem = newPage.items[safe: itemIndex]
                else { return false }
                return oldItem != newItem
            }
            .map { IndexPath(row: $0, section: pageIndex) }

            diffIndexPaths.append(contentsOf: indexPaths)
        }

        guard !diffIndexPaths.isEmpty else { return }

        for indexPath in diffIndexPaths {
            if let cell = tableView.cellForRow(at: indexPath) as? Cell,
               let item = itemAt(indexPath: indexPath) {
                cell.configure(arguments.cellBuilder(item))
            }
        }
    }

    func update(request: AnchorRequest<Item>) {
        isPageUpdating = true

        if let indexPath = indexPath(for: request.itemId) ?? middleIndexPath(in: pages) {
            tableView.layoutIfNeeded()
            let targetCellFrame = tableView.rectForRow(at: indexPath)
            tableView.setContentOffset(tableView.contentOffset, animated: false)
            let targetContentOffsetY = targetCellFrame.minY + (request.inset ?? arguments.defaultAnchorInset)

            UIView.animate(withDuration: request.animated ? 0.5 : 0.0) {
                self.tableView.contentOffset.y = targetContentOffsetY
            } completion: { _ in
                self.isPageUpdating = false
            }
        } else {
            isPageUpdating = false
        }
    }
}

// MARK: Center & Paging Detection

private extension PagingTableView {
    func indexPath(for itemId: Item.ID) -> IndexPath? {
        for (groupIndex, group) in pages.enumerated() {
            if let itemIndex = group.items.firstIndex(where: { $0.id == itemId }) {
                return IndexPath(row: itemIndex, section: groupIndex)
            }
        }
        return nil
    }

    func itemAt(indexPath: IndexPath) -> Item? {
        guard pages.indices.contains(indexPath.section),
              pages[indexPath.section].items.indices.contains(indexPath.row)
        else { return nil }
        return pages[indexPath.section].items[indexPath.row]
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
        let anchorY = tableView.contentOffset.y - arguments.defaultAnchorInset
        let anchorPoint = CGPoint(x: tableView.bounds.midX, y: anchorY)
        guard let indexPath = tableView.indexPathForRow(at: anchorPoint),
              let item = itemAt(indexPath: indexPath)
        else { return nil }
        return item.id
    }

    /// 현재 스크롤 상태가 페이징이 필요한 경계인지 판단해 방향을 반환합니다. 필요 없으면 nil. 부수효과 없음.
    func pagingDirectionNeeded() -> PageEndDirection? {
        let offsetY = tableView.contentOffset.y
        let maxOffsetY = max(tableView.contentSize.height - tableView.bounds.height, 0)
        guard maxOffsetY > 0 else { return nil }
        if offsetY <= 0 { return .top }
        if offsetY >= maxOffsetY { return .bottom }
        return nil
    }

    func prependedCount(
        _ oldPages: [Page<Item>],
        _ newPages: [Page<Item>]
    ) -> Int {
        guard let oldFirstId = oldPages.first?.id,
              let prependedCount = newPages.firstIndex(where: { $0.id == oldFirstId }),
              prependedCount > 0
        else { return 0 }

        // prepend된 아이템을 제외한 나머지가 같은지 확인
        let overlapCount = min(oldPages.count, newPages.count - prependedCount)
        for offset in 0 ..< overlapCount where newPages[prependedCount + offset].id != oldPages[offset].id {
            return 0
        }
        return prependedCount
    }

    func droppedCount(
        _ oldPages: [Page<Item>],
        _ newPages: [Page<Item>]
    ) -> Int {
        guard let newFirstId = newPages.first?.id,
              let droppedCount = oldPages.firstIndex(where: { $0.id == newFirstId }),
              droppedCount > 0
        else { return 0 }

        // drop된 아이템을 제외한 나머지가 같은지 확인
        let overlapCount = min(newPages.count, oldPages.count - droppedCount)
        for offset in 0 ..< overlapCount where oldPages[droppedCount + offset].id != newPages[offset].id {
            return 0
        }
        return droppedCount
    }
}
