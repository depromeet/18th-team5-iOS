import SwiftUI

/// 캘린더 날짜 이미지 클리핑 shape
/// SVG viewBox: 0 0 34 34
struct CalendarPhotoShape: Shape {
    func path(in rect: CGRect) -> SwiftUI.Path {
        var path = SwiftUI.Path()

        path.move(to: .init(x: 8.62143, y: 0))
        path.addLine(to: .init(x: 0.121429, y: 0))
        path.addLine(to: .init(x: 0.121429, y: 8.5))
        path.addCurve(
            to: .init(x: 7.54137, y: 16.932),
            control1: .init(x: 0.121429, y: 12.8285),
            control2: .init(x: 3.35692, y: 16.4014)
        )
        path.addCurve(
            to: .init(x: 0, y: 25.3786),
            control1: .init(x: 3.29826, y: 17.4083),
            control2: .init(x: 0, y: 21.0083)
        )
        path.addLine(to: .init(x: 0, y: 33.8786))
        path.addLine(to: .init(x: 8.5, y: 33.8786))
        path.addCurve(
            to: .init(x: 16.932, y: 26.4586),
            control1: .init(x: 12.8285, y: 33.8786),
            control2: .init(x: 16.4014, y: 30.643)
        )
        path.addCurve(
            to: .init(x: 25.3786, y: 34),
            control1: .init(x: 17.4083, y: 30.7018),
            control2: .init(x: 21.0083, y: 34)
        )
        path.addLine(to: .init(x: 33.8786, y: 34))
        path.addLine(to: .init(x: 33.8786, y: 25.5))
        path.addCurve(
            to: .init(x: 26.4586, y: 17.068),
            control1: .init(x: 33.8786, y: 21.1715),
            control2: .init(x: 30.643, y: 17.5986)
        )
        path.addCurve(
            to: .init(x: 34, y: 8.62143),
            control1: .init(x: 30.7018, y: 16.5917),
            control2: .init(x: 34, y: 12.9917)
        )
        path.addLine(to: .init(x: 34, y: 0.121429))
        path.addLine(to: .init(x: 25.5, y: 0.121428))
        path.addCurve(
            to: .init(x: 17.068, y: 7.54137),
            control1: .init(x: 21.1715, y: 0.121428),
            control2: .init(x: 17.5986, y: 3.35692)
        )
        path.addCurve(
            to: .init(x: 8.62143, y: 0),
            control1: .init(x: 16.5917, y: 3.29826),
            control2: .init(x: 12.9917, y: 0)
        )
        path.closeSubpath()

        let scaleX = rect.width / 34
        let scaleY = rect.height / 34
        return path.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
    }
}
