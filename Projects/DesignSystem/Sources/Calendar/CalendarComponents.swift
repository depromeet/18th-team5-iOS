//  CalendarComponents.swift
//  DesignSystem
//
//  Created by 송민교 on 5/7/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

// MARK: - CalendarHeaderView

public struct CalendarHeaderView: View {
    let title: String
    let onPrevious: () -> Void
    let onNext: () -> Void

    public init(title: String, onPrevious: @escaping () -> Void, onNext: @escaping () -> Void) {
        self.title = title
        self.onPrevious = onPrevious
        self.onNext = onNext
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.body2, \.semiBold)
                    .foregroundStyle(Color.gray500)

                Spacer()

                HStack(spacing: 12) {
                    Button(action: onPrevious) {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 8, height: 13)
                            .foregroundStyle(Color.gray900)
                    }
                    Button(action: onNext) {
                        Image(systemName: "chevron.right")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 8, height: 13)
                            .foregroundStyle(Color.gray900)
                    }
                }
            }
            .padding(.bottom, 12)

            Divider()
                .foregroundStyle(Color.gray100)
        }
    }
}

// MARK: - WeekdayLabelRow

public struct WeekdayLabelRow: View {
    private let labels = ["월", "화", "수", "목", "금", "토", "일"]

    public init() {}

    public var body: some View {
        HStack(spacing: 6) {
            ForEach(labels, id: \.self) { label in
                Text(label)
                    .font(.caption2, \.regular)
                    .foregroundStyle(Color.gray400)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - DayCell

public struct DayCell: View {
    let day: Int
    let imageURL: URL?
    let isSelected: Bool
    let onTap: (() -> Void)?

    public init(day: Int, imageURL: URL?, isSelected: Bool, onTap: (() -> Void)?) {
        self.day = day
        self.imageURL = imageURL
        self.isSelected = isSelected
        self.onTap = onTap
    }

    public var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(spacing: 2) {
                Text("\(day)")
                    .font(.caption1, \.regular)
                    .foregroundStyle(isSelected ? Color.monoWhite : Color.gray900)

                DayPhotoView(imageURL: imageURL, isSelected: isSelected)
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 8)
            .background(isSelected ? Color.gray900 : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - DayPhotoView

public struct DayPhotoView: View {
    let imageURL: URL?
    let isSelected: Bool

    public init(imageURL: URL?, isSelected: Bool) {
        self.imageURL = imageURL
        self.isSelected = isSelected
    }

    public var body: some View {
        Group {
            if let imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        Color.gray100
                    }
                }
                .frame(width: 34, height: 34)
                .clipShape(CalendarPhotoShape())
            } else {
                Color.clear
                    .frame(width: 34, height: 34)
            }
        }
    }
}
