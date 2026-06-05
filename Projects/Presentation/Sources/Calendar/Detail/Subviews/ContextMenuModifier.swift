//
//  ContextMenuModifier.swift
//  Presentation
//
//  Created by choijunios on 6/6/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

extension View {
    func contextMenus(
        verticalSpacing: CGFloat = .zero,
        @ViewBuilder menus: @escaping () -> some View
    ) -> some View {
        self.modifier(
            ContextMenuModifier(
                menusBuilder: menus,
                verticalSpacing: verticalSpacing
            )
        )
    }
}

struct ContextMenuModifier<MenuViews: View>: ViewModifier {
    @State private var triggerFrame: CGRect = .zero
    @State private var menuPresents: Bool = false
    @State private var menusViewSize: CGSize = .zero
    @State private var screenSize: CGSize = .zero

    @ViewBuilder var menusBuilder: () -> MenuViews
    let verticalSpacing: CGFloat

    func body(content: Content) -> some View {
        triggerView(content)
            .onGeometryChange(for: CGRect.self) { proxy in
                proxy.frame(in: .global)
            } action: { triggerFrame = $0 }
            .fullScreenCover(isPresented: $menuPresents) {
                menusView
                    .introspect(.viewController, on: .iOS(.v16...)) { vc in
                        vc.modalPresentationStyle = .overFullScreen
                        vc.view.backgroundColor = .clear
                    }
            }
    }

    private func triggerView(_ content: Content) -> some View {
        Button {
            setPresents(true)
        } label: {
            content
        }
    }

    private func setPresents(_ value: Bool) {
        var transaction = Transaction()
        transaction.animation = nil
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            menuPresents = value
        }
    }

    var menusView: some View {
        ZStack {
            menusViewBackground

            VStack(spacing: 12) {
                menusBuilder()
            }
            .padding(16)
            .background {
                ZStack {
                    BackgroundBlurView(style: .systemUltraThinMaterialLight)
                    Color.whiteAlpha600
                        .opacity(0.65)
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.white, lineWidth: 1)
                }
            }
            .onGeometryChange(
                for: CGSize.self,
                of: { $0.size }
            ) { menusViewSize = $0 }
            .position(
                x: menusViewXPos + menusViewSize.width / 2,
                y: menusViewYPos + menusViewSize.height / 2
            )
        }
        .ignoresSafeArea()
        .onGeometryChange(
            for: CGSize.self,
            of: { $0.size }
        ) { screenSize = $0 }
    }

    var menusViewXPos: CGFloat {
        if triggerFrame.midX > (screenSize.width / 2) {
            triggerFrame.maxX - menusViewSize.width
        } else {
            triggerFrame.minX
        }
    }

    var menusViewYPos: CGFloat {
        // 아래로 노출로 고정
        triggerFrame.maxY + verticalSpacing
    }

    var menusViewBackground: some View {
        Color.clear
            .contentShape(Rectangle())
            .ignoresSafeArea()
            .onTapGesture {
                setPresents(false)
            }
    }
}

#Preview {
    let view = Text("트리거")
        .frame(width: 100, height: 50)
        .border(.red)
        .contextMenu {
            Text("메뉴1")
            Text("메뉴메뉴2")
            Text("메뉴메뉴메뉴3")
            Text("메뉴메뉴메뉴메뉴4")
            Text("메뉴메뉴메뉴메뉴메뉴5")
        }
    HStack {
        VStack {
            view
            Spacer()
            view
        }

        Spacer()

        VStack {
            view
            Spacer()
            view
        }
    }
    .padding(50)
}
