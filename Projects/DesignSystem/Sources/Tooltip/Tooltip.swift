//
//  Tooltip.swift
//  DesignSystem
//
//  Created by 이정원 on 5/22/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

public struct Tooltip: View {
    public enum Position {
        case rightTop
        case leftTop
    }

    @Binding private var isPresented: Bool
    @State private var dismissTask: Task<Void, Never>?
    private let text: String
    private let position: Position

    public init(
        text: String,
        position: Position,
        isPresented: Binding<Bool>
    ) {
        self.text = text
        self.position = position
        self._isPresented = isPresented
    }

    public var body: some View {
        ZStack(alignment: alignment) {
            if isPresented {
                textView
                    .padding(.top, 12)
                arrow
                    .padding(position)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isPresented)
        .onAppear { dismiss() }
        .onChange(of: isPresented) { _, newValue in
            guard newValue else { return }
            dismiss()
        }
        .onDisappear { dismissTask?.cancel() }
    }
}

private extension Tooltip {
    var alignment: Alignment {
        switch position {
        case .leftTop: .topLeading
        case .rightTop: .topTrailing
        }
    }

    func dismiss() {
        dismissTask?.cancel()
        dismissTask = Task {
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }

            await MainActor.run {
                isPresented = false
            }
        }
    }
}

private extension Tooltip {
    var arrow: some View {
        Image.icRoundedTriangle
            .renderingMode(.template)
            .resizable()
            .frame(width: 12, height: 12)
            .foregroundStyle(Color.white)
    }

    var textView: some View {
        Text(text)
            .font(.caption1Semibold)
            .foregroundStyle(Color.gray800)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: .radius12))
            .shadow(color: Color.blackAlpha300, radius: 20, x: 0, y: 8)
    }
}

private extension View {
    func padding(_ position: Tooltip.Position) -> some View {
        switch position {
        case .leftTop: self.padding(.leading, 12)
        case .rightTop: self.padding(.trailing, 12)
        }
    }
}
