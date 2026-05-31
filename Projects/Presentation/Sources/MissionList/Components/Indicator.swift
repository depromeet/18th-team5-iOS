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

    private let selectedWidth: CGFloat = 20
    private let selectedHeight: CGFloat = 24
    private let selectedInactiveHeight: CGFloat = 4
    private let unselectedWidth: CGFloat = 10
    private let unselectedHeight: CGFloat = 2
    private let itemSpacing: CGFloat = 8
    private let contentPadding: CGFloat = 6

    private let totalCount: Int
    private let selectedIndex: Int
    private let mainColor: Color
    private let subColor: Color
    private let indexChanged: (Int) -> Void

    init(
        totalCount: Int,
        selectedIndex: Int,
        mainColor: Color,
        subColor: Color,
        isEnabled: Binding<Bool>,
        indexChanged: @escaping (Int) -> Void
    ) {
        self.totalCount = totalCount
        self.selectedIndex = selectedIndex
        self.mainColor = mainColor
        self.subColor = subColor
        self._isEnabled = isEnabled
        self.indexChanged = indexChanged
    }

    var body: some View {
        VStack(spacing: itemSpacing) {
            ForEach(0 ..< totalCount, id: \.self) { index in
                Group {
                    if index == selectedIndex {
                        selectedCapsuleView
                    } else {
                        unselectedCapsuleView
                    }
                }
            }
        }
        .padding(contentPadding)
        .contentShape(Rectangle())
        .gesture(dragGesture)
        .animation(.easeInOut(duration: 0.25), value: isEnabled)
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
            .frame(width: unselectedWidth, height: unselectedHeight)
            .foregroundStyle(Color.gray500)
    }

    @ViewBuilder
    var selectedCapsuleView: some View {
        if isEnabled {
            ZStack {
                subColor
                    .frame(width: selectedWidth, height: selectedWidth)
                    .clipShape(Circle())

                mainColor
                    .frame(width: 12, height: 12)
                    .clipShape(Circle())
            }
            .padding(.vertical, 2)
            .frame(height: selectedHeight)
        } else {
            Capsule()
                .frame(width: selectedWidth, height: selectedInactiveHeight)
                .foregroundStyle(mainColor)
        }
    }

    func startActivationTaskIfNeeded() {
        guard activationTask == nil else { return }

        activationTask = Task {
            try? await Task.sleep(for: .seconds(0.5))
            guard !Task.isCancelled else { return }

            await MainActor.run {
                guard let latestLocation else { return }
                isEnabled = true
                updateIndex(at: latestLocation)
            }
        }
    }

    func updateIndex(at location: CGPoint) {
        guard totalCount > 0 else { return }
        let index = nearestIndex(to: location.y)

        guard index != lastChangedIndex else { return }
        lastChangedIndex = index
        indexChanged(index)
    }

    func nearestIndex(to locationY: CGFloat) -> Int {
        var itemTop = contentPadding
        var nearestIndex = 0
        var nearestDistance = CGFloat.greatestFiniteMagnitude

        for index in 0 ..< totalCount {
            let centerY = itemTop + itemHeight(at: index) / 2
            let distance = abs(locationY - centerY)

            if distance < nearestDistance {
                nearestDistance = distance
                nearestIndex = index
            }

            itemTop += itemHeight(at: index) + itemSpacing
        }

        return nearestIndex
    }

    func itemHeight(at index: Int) -> CGFloat {
        guard index == selectedIndex else {
            return unselectedHeight
        }

        return isEnabled ? selectedHeight : selectedInactiveHeight
    }
}
