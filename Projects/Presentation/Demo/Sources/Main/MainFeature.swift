//
//  MainFeature.swift
//  PresentationDemo
//
//  Created by 이정원 on 4/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture

@Reducer
struct MainFeature {
    @ObservableState
    struct State {
        var tab: Tab = .home
        var home: HomeFeature.State = .init()
        var archive: ArchiveFeature.State = .init()
        var myPage: MyPageFeature.State = .init()
    }

    enum Action: BindableAction {
        case home(HomeFeature.Action)
        case archive(ArchiveFeature.Action)
        case myPage(MyPageFeature.Action)
        case binding(BindingAction<State>)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()

        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }

        Scope(state: \.archive, action: \.archive) {
            ArchiveFeature()
        }

        Scope(state: \.myPage, action: \.myPage) {
            MyPageFeature()
        }

        Reduce { _, action in
            switch action {
            case .home, .archive, .myPage: return .none
            case .binding: return .none
            }
        }
    }
}

extension MainFeature {
    enum Tab: CaseIterable {
        case home
        case archive
        case myPage
    }
}
