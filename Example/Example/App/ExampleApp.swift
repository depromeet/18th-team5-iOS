import ComposableArchitecture
import SwiftUI

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(store:
                .init(initialState: .init()) {
                    RootFeature()
                }
            )
        }
    }
}
