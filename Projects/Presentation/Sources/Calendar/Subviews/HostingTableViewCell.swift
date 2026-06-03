//
//  HostingTableViewCell.swift
//  Presentation
//
//  Created by choijunios on 5/26/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import SwiftUI

final class HostingTableViewCell<RootView: View>: UITableViewCell {
    private var hostingController: UIHostingController<RootView>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupAppearance()
    }

    required init?(coder: NSCoder) { nil }

    @discardableResult
    func configure(_ rootView: RootView) -> Self {
        if let hostingController {
            hostingController.rootView = rootView
        } else {
            let controller = UIHostingController(rootView: rootView)
            controller.view.backgroundColor = .clear
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            controller.safeAreaRegions = []

            contentView.addSubview(controller.view)
            NSLayoutConstraint.activate([
                controller.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                controller.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                controller.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                controller.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
            hostingController = controller
        }
        return self
    }
}

private extension HostingTableViewCell {
    func setupAppearance() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = true
    }
}
