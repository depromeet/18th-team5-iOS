//
//  FreeRecordDateSelectionSheet.swift
//  Presentation
//
//  Created by 진준호 on 6/12/26.
//  Copyright © 2026 Orange. All rights reserved.
//

import DesignSystem
import SwiftUI
import UIKit

struct FreeRecordDateSelectionSheet: View {
    @Binding var selectedDate: Date

    let confirmedDate: Date
    let selectableDateRange: ClosedRange<Date>?
    let onClose: () -> Void
    let onConfirm: () -> Void

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 0) {
            indicator
            header

            dateWheelPicker
                .frame(height: 144)
                .clipped()
                .padding(.horizontal, 20)

            BottomButton(title: "확인") {
                onConfirm()
            }
            .disabled(!isConfirmEnabled)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color.monoWhite)
    }
}

private extension FreeRecordDateSelectionSheet {
    var indicator: some View {
        Capsule()
            .frame(width: 36, height: 5)
            .foregroundStyle(Color.gray200)
            .padding(.vertical, 6)
    }

    var header: some View {
        ZStack {
            Text("날짜 변경하기")
                .font(.body1Medium)
                .foregroundStyle(Color.gray900)

            HStack {
                Button(action: onClose) {
                    Image.icClose
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color.monoWhite)
                        .padding(12)
                        .background(Color.blackAlpha600)
                        .clipShape(Circle())
                }

                Spacer()
            }
        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 16, trailing: 20))
    }

    var dateWheelPicker: some View {
        ZStack {
            HStack(spacing: FreeRecordDateWheelPicker.componentSpacing) {
                pickerSelectionBackground(width: FreeRecordDateWheelPicker.yearWidth)

                pickerSelectionBackground(width: FreeRecordDateWheelPicker.monthWidth)

                pickerSelectionBackground(width: FreeRecordDateWheelPicker.dateWidth)
            }
            .frame(height: FreeRecordDateWheelPicker.rowHeight)
            .allowsHitTesting(false)

            FreeRecordDateWheelPicker(
                selectedDate: $selectedDate,
                selectableDates: selectableDates
            )
        }
    }

    var selectableDates: [Date] {
        guard let selectableDateRange else {
            return [calendar.startOfDay(for: selectedDate)]
        }

        var dates: [Date] = []
        var currentDate = calendar.startOfDay(for: selectableDateRange.lowerBound)
        let endDate = calendar.startOfDay(for: selectableDateRange.upperBound)

        while currentDate <= endDate {
            dates.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }

        return dates
    }

    var isConfirmEnabled: Bool {
        !Calendar.current.isDate(selectedDate, inSameDayAs: confirmedDate)
    }

    func pickerSelectionBackground(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: .radius16)
            .fill(Color.gray100)
            .frame(width: width, height: 32)
    }
}

private struct FreeRecordDateWheelPicker: UIViewRepresentable {
    static let yearWidth: CGFloat = 80
    static let monthWidth: CGFloat = 56
    static let dateWidth: CGFloat = 116
    static let componentSpacing: CGFloat = 16
    static let rowHeight: CGFloat = 34

    @Binding var selectedDate: Date

    let selectableDates: [Date]

    private let calendar = Calendar.current

    func makeUIView(context: Context) -> UIPickerView {
        let pickerView = SelectionBackgroundHiddenPickerView()
        pickerView.dataSource = context.coordinator
        pickerView.delegate = context.coordinator
        pickerView.backgroundColor = .clear
        pickerView.clipsToBounds = true
        return pickerView
    }

    func updateUIView(_ pickerView: UIPickerView, context: Context) {
        context.coordinator.parent = self
        pickerView.reloadAllComponents()
        pickerView.hideSystemSelectionBackground()

        selectCurrentRows(in: pickerView, animated: false)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    private func selectCurrentRows(in pickerView: UIPickerView, animated: Bool) {
        let selectedYear = calendar.component(.year, from: selectedDate)
        let selectedMonth = calendar.component(.month, from: selectedDate)
        let normalizedDate = calendar.startOfDay(for: selectedDate)

        if let yearIndex = yearValues.firstIndex(of: selectedYear) {
            pickerView.selectRow(yearIndex, inComponent: Component.year.rawValue, animated: animated)
        }

        if let monthIndex = monthValues.firstIndex(of: selectedMonth) {
            pickerView.selectRow(monthIndex, inComponent: Component.month.rawValue, animated: animated)
        }

        if let dateIndex = selectableDates.firstIndex(where: { calendar.isDate($0, inSameDayAs: normalizedDate) }) {
            pickerView.selectRow(dateIndex, inComponent: Component.date.rawValue, animated: animated)
        }
    }
}

private extension FreeRecordDateWheelPicker {
    enum Component: Int, CaseIterable {
        case year
        case yearMonthSpacing
        case month
        case monthDateSpacing
        case date

        var isSpacing: Bool {
            switch self {
            case .yearMonthSpacing, .monthDateSpacing:
                true
            case .year, .month, .date:
                false
            }
        }
    }

    var yearValues: [Int] {
        selectableDates
            .map { calendar.component(.year, from: $0) }
            .uniqued()
    }

    var monthValues: [Int] {
        let selectedYear = calendar.component(.year, from: selectedDate)
        return selectableDates
            .filter { calendar.component(.year, from: $0) == selectedYear }
            .map { calendar.component(.month, from: $0) }
            .uniqued()
    }

    func updateSelectedDate(year: Int) {
        let selectedMonth = calendar.component(.month, from: selectedDate)
        let datesInYear = selectableDates.filter {
            calendar.component(.year, from: $0) == year
        }
        let hasSelectedMonth = datesInYear.contains {
            calendar.component(.month, from: $0) == selectedMonth
        }

        if hasSelectedMonth {
            updateSelectedDate(year: year, month: selectedMonth)
        } else if let firstDate = datesInYear.first {
            selectedDate = firstDate
        }
    }

    func updateSelectedDate(month: Int) {
        updateSelectedDate(year: calendar.component(.year, from: selectedDate), month: month)
    }

    func updateSelectedDate(year: Int, month: Int) {
        let selectedDay = calendar.component(.day, from: selectedDate)
        let datesInMonth = selectableDates.filter {
            calendar.component(.year, from: $0) == year
                && calendar.component(.month, from: $0) == month
        }

        guard let closestDate = datesInMonth.min(by: { lhs, rhs in
            abs(calendar.component(.day, from: lhs) - selectedDay)
                < abs(calendar.component(.day, from: rhs) - selectedDay)
        }) else { return }

        selectedDate = closestDate
    }

    static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
}

extension FreeRecordDateWheelPicker {
    final class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: FreeRecordDateWheelPicker

        init(parent: FreeRecordDateWheelPicker) {
            self.parent = parent
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            Component.allCases.count
        }

        func pickerView(
            _ pickerView: UIPickerView,
            numberOfRowsInComponent component: Int
        ) -> Int {
            switch Component(rawValue: component) {
            case .year:
                parent.yearValues.count
            case .yearMonthSpacing, .monthDateSpacing:
                1
            case .month:
                parent.monthValues.count
            case .date:
                parent.selectableDates.count
            case .none:
                0
            }
        }

        func pickerView(
            _ pickerView: UIPickerView,
            widthForComponent component: Int
        ) -> CGFloat {
            switch Component(rawValue: component) {
            case .year:
                FreeRecordDateWheelPicker.yearWidth
            case .yearMonthSpacing, .monthDateSpacing:
                FreeRecordDateWheelPicker.componentSpacing
            case .month:
                FreeRecordDateWheelPicker.monthWidth
            case .date:
                FreeRecordDateWheelPicker.dateWidth
            case .none:
                0
            }
        }

        func pickerView(
            _ pickerView: UIPickerView,
            rowHeightForComponent component: Int
        ) -> CGFloat {
            FreeRecordDateWheelPicker.rowHeight
        }

        func pickerView(
            _ pickerView: UIPickerView,
            viewForRow row: Int,
            forComponent component: Int,
            reusing view: UIView?
        ) -> UIView {
            let label = (view as? UILabel) ?? UILabel()
            guard Component(rawValue: component)?.isSpacing == false else {
                label.text = nil
                label.backgroundColor = .clear
                return label
            }

            label.textAlignment = .center
            label.font = Typography.headline1Medium.uiFont
            label.textColor = UIColor(Color.gray900)
            label.backgroundColor = .clear
            label.text = title(for: row, component: component)
            return label
        }

        func pickerView(
            _ pickerView: UIPickerView,
            didSelectRow row: Int,
            inComponent component: Int
        ) {
            switch Component(rawValue: component) {
            case .year:
                guard parent.yearValues.indices.contains(row) else { return }
                parent.updateSelectedDate(year: parent.yearValues[row])
            case .yearMonthSpacing, .monthDateSpacing:
                return
            case .month:
                guard parent.monthValues.indices.contains(row) else { return }
                parent.updateSelectedDate(month: parent.monthValues[row])
            case .date:
                guard parent.selectableDates.indices.contains(row) else { return }
                parent.selectedDate = parent.selectableDates[row]
            case .none:
                return
            }
        }

        private func title(for row: Int, component: Int) -> String {
            switch Component(rawValue: component) {
            case .year:
                guard parent.yearValues.indices.contains(row) else { return "" }
                return "\(parent.yearValues[row])년"
            case .yearMonthSpacing, .monthDateSpacing:
                return ""
            case .month:
                guard parent.monthValues.indices.contains(row) else { return "" }
                return "\(parent.monthValues[row])월"
            case .date:
                guard parent.selectableDates.indices.contains(row) else { return "" }
                let date = parent.selectableDates[row]
                let day = parent.calendar.component(.day, from: date)
                let weekday = FreeRecordDateWheelPicker.weekdayFormatter.string(from: date)
                return "\(day)일   \(weekday)"
            case .none:
                return ""
            }
        }
    }
}

private extension UIPickerView {
    func hideSystemSelectionBackground() {
        DispatchQueue.main.async {
            self.hideSystemSelectionBackgroundRecursively(in: self, isRoot: true)
        }
    }

    func hideSystemSelectionBackgroundRecursively(in view: UIView, isRoot: Bool) {
        view.subviews.forEach { subview in
            let typeName = String(describing: type(of: subview))
            let isSelectionView = typeName.localizedCaseInsensitiveContains("selection")
            let isSeparator = subview.bounds.height <= 1
            let isSystemRowBackground = isRoot
                && subview.bounds.height <= FreeRecordDateWheelPicker.rowHeight + 4
                && abs(subview.frame.midY - bounds.midY) <= FreeRecordDateWheelPicker.rowHeight
                && !(subview is UILabel)

            if isSelectionView || isSeparator || isSystemRowBackground {
                subview.backgroundColor = .clear
                subview.isHidden = true
                subview.alpha = 0
            } else {
                hideSystemSelectionBackgroundRecursively(in: subview, isRoot: false)
            }
        }
    }
}

private final class SelectionBackgroundHiddenPickerView: UIPickerView {
    override func layoutSubviews() {
        super.layoutSubviews()
        hideSystemSelectionBackground()
    }
}

private extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}

#Preview {
    FreeRecordDateSelectionSheet(
        selectedDate: .constant(Date()),
        confirmedDate: Date(),
        selectableDateRange: Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            ... Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
        onClose: {},
        onConfirm: {}
    )
}
