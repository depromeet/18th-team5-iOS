//
//  Mission+.swift
//  Data
//
//  Created by 이정원 on 6/22/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain

extension Mission {
    var analyticsCategoryValue: String? {
        theme?.analyticsValue ?? attribute?.category?.analyticsValue
    }
}
