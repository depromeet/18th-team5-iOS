//
//  SharedKey+.swift
//  Presentation
//
//  Created by 이정원 on 7/22/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import Domain
import Sharing

extension SharedKey where Self == InMemoryKey<SolarTerm>.Default {
    static var solarTerm: Self {
        Self[.inMemory("solarTerm"), default: .ibha]
    }
}
