//
//  SampleParentControlFeature.swift
//  Presentation
//
//  Created by 송민교 on 4/21/26.
//  Copyright © 2026 Orange. All rights reserved.
//

// [Sample] Pattern 1 - Parent → Child
// 부모가 자식에게 직접 액션을 전달하거나 자식 State를 직접 수정
import ComposableArchitecture

@Reducer
struct SampleParentControlFeature {
    @ObservableState
    struct State: Equatable {
        var counter: SampleCounterFeature.State = .init()
    }

    enum Action {
        case counter(SampleCounterFeature.Action)
        /// 부모 버튼 → 자식 액션 전달
        case resetCounterTapped
        /// 부모가 자식 State를 직접 수정
        case doubleCountTapped
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.counter, action: \.counter) {
            SampleCounterFeature()
        }

        Reduce { state, action in
            switch action {
            case .resetCounterTapped:
                // 부모 → 자식 액션 전달
                return .send(.counter(.reset))

            case .doubleCountTapped:
                // 부모가 자식 State를 직접 읽고 수정
                state.counter.count *= 2
                return .none

            case .counter:
                return .none
            }
        }
    }
}
