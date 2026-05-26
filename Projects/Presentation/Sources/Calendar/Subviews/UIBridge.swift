//
//  UIBridge.swift
//  Presentation
//
//  Created by choijunios on 5/26/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Combine
import SwiftUI

protocol BridgingUIView: UIView {
    associatedtype Action
    associatedtype State: Equatable
    associatedtype Arguments

    var action: AnyPublisher<Action, Never> { get }

    init(arguments: Arguments)

    func bind(_ context: AnyPublisher<UpdateContext<State>, Never>)
}

// MARK: UIBridge

struct UpdateContext<State: Equatable> {
    let state: State
    let environment: EnvironmentValues?
    let transaction: Transaction?
}

struct UIBridge<UIKitView: BridgingUIView>: UIViewRepresentable {
    typealias State = UIKitView.State
    typealias Action = UIKitView.Action
    typealias Arguments = UIKitView.Arguments

    let state: State
    let actionHandler: (Action) -> Void
    let arguments: Arguments

    func makeCoordinator() -> BridgeCoordinator {
        // environment/transaction은 makeUIView 시점에 주입되므로 이 시점엔 nil.
        BridgeCoordinator(
            context: .init(
                state: state,
                environment: nil,
                transaction: nil
            ),
            actionHandler: actionHandler
        )
    }

    func makeUIView(context: Context) -> UIKitView {
        let uiview = UIKitView(arguments: arguments)
        let coordinator = context.coordinator

        // 순서 중요: bind 이전에 최신 context로 갱신해야
        // @Published 초기 구독 시 stale 값이 한 번 더 방출되지 않는다.
        coordinator.context = makeUpdateContext(state, context)
        coordinator.bind(uiview.action)
        uiview.bind(coordinator.$context.eraseToAnyPublisher())
        return uiview
    }

    func updateUIView(_ uiView: UIKitView, context: Context) {
        // 상태 변경은 @Published를 통해 UIView 측 bind 스트림으로 단방향 전달.
        context.coordinator.context = makeUpdateContext(state, context)
    }

    private func makeUpdateContext(_ state: State, _ context: Context) -> UpdateContext<State> {
        UpdateContext(
            state: state,
            environment: context.environment,
            transaction: context.transaction
        )
    }

    final class BridgeCoordinator: ObservableObject {
        @Published var context: UpdateContext<State>
        private let actionHandler: (Action) -> Void
        private var actionStreamCancellable: AnyCancellable?

        init(context: UpdateContext<State>, actionHandler: @escaping (Action) -> Void) {
            self._context = Published(initialValue: context)
            self.actionHandler = actionHandler
        }

        func bind(_ action: AnyPublisher<Action, Never>) {
            actionStreamCancellable = action
                .sink { [weak self] action in
                    self?.actionHandler(action)
                }
        }
    }
}
