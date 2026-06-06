//
//  ToastView.swift
//  DesignSystem
//
//  Created by choijunios on 6/6/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Dependencies
import SwiftUI

public extension View {
    // 토스트를 표시할 뷰에 부착(전체 너비를 차지하는 뷰 권장)
    func toastContainer() -> some View {
        modifier(ToastContainerModifier())
    }

    // 토스트를 전송할 뷰에 부착
    func presentToast(_ toast: Binding<ToastModel?>) -> some View {
        modifier(ToastSenderModifier(toast: toast))
    }
}

enum ToastManagerKey: DependencyKey {
    static let liveValue = ToastManager()
}

public extension DependencyValues {
    var toastManager: ToastManager {
        get { self[ToastManagerKey.self] }
        set { self[ToastManagerKey.self] = newValue }
    }
}

// MARK: Manager

@Observable
public final class ToastManager {
    private(set) var toasts: [ToastModel] = []

    func add(_ toast: ToastModel) {
        toasts.append(toast)
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(toast.duration))

            guard let index = self?.toasts.firstIndex(where: { $0.id == toast.id })
            else { return }
            self?.toasts.remove(at: index)
        }
    }
}

// MARK: View

struct ToastView: View {
    let model: ToastModel

    var body: some View {
        HStack(spacing: 16) {
            Text(model.title)
                .font(.body1Medium)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let action = model.action {
                Button {
                    action.onAction()
                } label: {
                    Text(action.title)
                        .font(.body2Medium)
                        .foregroundStyle(Color.gray50)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background {
                            Capsule()
                                .fill(Color.gray700)
                        }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray800)
        }
    }
}

// MARK: Sender

struct ToastSenderModifier: ViewModifier {
    @Dependency(\.toastManager) private var toastManager
    @Binding var toast: ToastModel?

    func body(content: Content) -> some View {
        content
            .onChange(of: toast) { _, newToast in
                guard let newToast else { return }
                toastManager.add(newToast)
            }
    }
}

// MARK: Reciever

struct ToastContainerModifier: ViewModifier {
    @Dependency(\.toastManager) private var toastManager
    @State private var toastViewHeight: CGFloat = .zero

    func body(content: Content) -> some View {
        content
            .overlay {
                ZStack(alignment: .bottom) {
                    Color.clear

                    ForEach(toastManager.toasts) { toast in
                        ToastView(model: toast)
                            .onGeometryChange(
                                for: CGFloat.self,
                                of: { $0.size.height }
                            ) { toastViewHeight = $0 }
                            .padding(.horizontal, 20)
                            .padding(.bottom, toast.bottomInset)
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut, value: toastManager.toasts)
            }
    }
}

#Preview {
    @Previewable @State var toast: ToastModel?

    ZStack {
        Color.clear
        Button("토스트 표출") {
            toast = .init(
                title: "토스트 제목 예제",
                duration: 2,
                bottomInset: 30,
                action: .init(title: "버튼1", onAction: {
                    print("버튼탭")
                })
            )
        }
        .presentToast($toast)
    }
    .border(.red)
    .toastContainer()
}
