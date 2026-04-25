//
//  ExampleView.swift
//  PresentationDemo
//
//  Created by 진준호 on 4/20/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct ExampleView: View {
    @Bindable private var store: StoreOf<ExampleFeature>

    init(store: StoreOf<ExampleFeature>) {
        self.store = store
    }

    var body: some View {
        List {
            statusSection
            groupSections
        }
        .navigationTitle("예시 목록")
        .onAppear {
            store.send(.onAppear)
        }
        .sheet(isPresented: isDetailPresented) {
            if let detail = store.selectedDetail {
                ExampleDetailView(detail: detail)
            }
        }
    }

    private var isDetailPresented: Binding<Bool> {
        Binding(
            get: { store.selectedDetail != nil },
            set: { if !$0 { store.send(.dismissDetail) } }
        )
    }
}

// MARK: - 섹션 뷰

private extension ExampleView {
    @ViewBuilder
    var statusSection: some View {
        if store.isLoading {
            ProgressView("로딩 중...")
                .frame(maxWidth: .infinity)
                .listRowSeparator(.hidden)
        }

        if let errorMessage = store.errorMessage {
            Text("오류: \(errorMessage)")
                .foregroundStyle(.red)
        }
    }

    var groupSections: some View {
        ForEach(store.categoryGroups) { group in
            Section {
                ForEach(group.items, id: \.id) { detail in
                    Button {
                        store.send(.itemTapped(id: detail.id))
                    } label: {
                        ExampleItemRow(detail: detail)
                    }
                }
            } header: {
                groupHeader(group: group)
            }
        }
    }

    func groupHeader(group: CategoryGroup) -> some View {
        HStack {
            Text(group.category.displayName)
                .font(.headline)
            Spacer()
            Text("완료율: \(Int(group.completionRate * 100))%")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - 아이템 행 뷰

private struct ExampleItemRow: View {
    let detail: ExampleDetail

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(detail.title)
                .font(.body)
                .foregroundStyle(.primary)

            HStack {
                ForEach(detail.tags, id: \.self) { tag in
                    Text("#\(tag)")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.blue.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 상세 뷰

private struct ExampleDetailView: View {
    let detail: ExampleDetail

    var body: some View {
        NavigationStack {
            List {
                basicInfoSection
                contentSection
                tagsSection
                imageSection
            }
            .navigationTitle("상세 정보")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var basicInfoSection: some View {
        Section("기본 정보") {
            LabeledContent("제목", value: detail.title)
            LabeledContent("카테고리", value: detail.category.displayName)
        }
    }

    private var contentSection: some View {
        Section("내용") {
            Text(detail.content)
        }
    }

    private var tagsSection: some View {
        Section("태그") {
            ForEach(detail.tags, id: \.self) { tag in
                Text("#\(tag)")
            }
        }
    }

    @ViewBuilder
    private var imageSection: some View {
        if let imageURL = detail.imageURL {
            Section("이미지") {
                Text(imageURL.absoluteString)
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
        }
    }
}

// MARK: - Category 표시용 Extension

extension ExampleDetail.Category {
    var displayName: String {
        switch self {
        case .general:
            "일반"
        case .important:
            "중요"
        case .archived:
            "보관됨"
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ExampleView(
            store: Store(
                initialState: ExampleFeature.State()
            ) {
                ExampleFeature()
            } withDependencies: {
                $0.exampleRepository = .previewValue
            }
        )
    }
}
