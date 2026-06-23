//
//  PicturePermissionKind+.swift
//  Data
//
//  Created by 이정원 on 6/23/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain

extension PicturePermissionKind {
    var analyticsValue: String {
        switch self {
        case .camera: "camera"
        case .photoLibrary: "gallery"
        }
    }
}
