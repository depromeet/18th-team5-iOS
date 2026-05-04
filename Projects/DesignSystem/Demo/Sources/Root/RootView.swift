//
//  RootView.swift
//  DesignSystemDemo
//
//  Created by 이정원 on 4/25/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationStack {
            List(Menu.allCases, id: \.self) { menu in
                NavigationLink(menu.name, value: menu)
            }
            .padding(.top, 40)
            .background(background)
            .navigationTitle("Design System Demo")
            .navigationDestination(for: Menu.self) { menu in
                demoView(menu: menu)
            }
        }
    }
}

private extension RootView {
    @ViewBuilder
    func demoView(menu: Menu) -> some View {
        switch menu {
        case .carousel: CarouselDemoView()
        case .circularWheelPicker: CircularWheelPickerDemoView()
        case .font: FontDemoView()
        }
    }

    var background: some View {
        Color(uiColor: .systemGroupedBackground)
            .ignoresSafeArea()
    }
}
