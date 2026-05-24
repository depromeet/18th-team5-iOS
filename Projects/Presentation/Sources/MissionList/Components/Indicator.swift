//
//  Indicator.swift
//  Presentation
//
//  Created by 이정원 on 5/24/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI

struct Indicator: View {
    @Binding private var isEnabled: Bool
    @State private var activationTask: Task<Void, Never>?
    @State private var lastChangedIndex: Int?
    @State private var latestLocation: CGPoint?

    private let totalCount: Int
    private let selectedIndex: Int
    private let mainColor: Color
    private let indexChanged: (Int) -> Void

    init(
        totalCount: Int,
        selectedIndex: Int,
        mainColor: Color,
        isEnabled: Binding<Bool>,
        indexChanged: @escaping (Int) -> Void
    ) {
        self.totalCount = totalCount
        self.selectedIndex = selectedIndex
        self.mainColor = mainColor
        self._isEnabled = isEnabled
        self.indexChanged = indexChanged
    }

    var body: some View {
        VStack(spacing: 8) {
            ForEach(0 ..< totalCount, id: \.self) { index in
                Group {
                    switch index == selectedIndex {
                    case true: selectedCapsuleView
                    case false: unselectedCapsuleView
                    }
                }
                .frame(width: 20, height: 4)
            }
        }
        .padding(6)
        .contentShape(Rectangle())
        .gesture(dragGesture)
        .sensoryFeedback(
            .impact(weight: .heavy), trigger: isEnabled
        ) { _, newValue in
            newValue
        }
        .onDisappear {
            activationTask?.cancel()
            isEnabled = false
        }
    }
}

private extension Indicator {
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                latestLocation = value.location
                startActivationTaskIfNeeded()

                guard isEnabled else { return }
                updateIndex(at: value.location)
            }
            .onEnded { value in
                if isEnabled {
                    updateIndex(at: value.location)
                }

                activationTask?.cancel()
                activationTask = nil
                lastChangedIndex = nil
                latestLocation = nil
                isEnabled = false
            }
    }

    var unselectedCapsuleView: some View {
        Capsule()
            .frame(width: 10, height: 2)
            .foregroundStyle(Color.gray500)
    }

    var selectedCapsuleView: some View {
        Capsule()
            .frame(width: 20, height: 4)
            .foregroundStyle(mainColor)
    }

    func startActivationTaskIfNeeded() {
        guard activationTask == nil else { return }

        activationTask = Task {
            try? await Task.sleep(for: .seconds(0.5))
            guard !Task.isCancelled else { return }

            await MainActor.run {
                guard let latestLocation else { return }
                isEnabled = true
                lastChangedIndex = selectedIndex
                updateIndex(at: latestLocation)
            }
        }
    }

    func updateIndex(at location: CGPoint) {
        guard totalCount > 0 else { return }

        let rowStride: CGFloat = 12
        let firstCenterY: CGFloat = 8
        let rawIndex = ((location.y - firstCenterY) / rowStride).rounded()
        let index = min(max(Int(rawIndex), 0), totalCount - 1)

        guard index != lastChangedIndex else { return }
        lastChangedIndex = index
        indexChanged(index)
    }
}
