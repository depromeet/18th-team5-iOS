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

    @ViewBuilder
    var dateWheelPicker: some View {
        let yearRows = yearValues.map { "\($0)년" }
        let monthRows = monthValues.map { "\($0)월" }
        let dateRows = selectableDates.map(dateTitle)

        HStack(spacing: FreeRecordDateWheelLayout.componentSpacing) {
            pickerColumn(
                width: columnWidth(for: yearRows, minimumWidth: FreeRecordDateWheelLayout.minimumYearWidth),
                rows: yearRows,
                selectedIndex: yearSelectedIndex
            ) { index in
                guard yearValues.indices.contains(index) else { return }
                updateSelectedDate(year: yearValues[index])
            }

            pickerColumn(
                width: columnWidth(for: monthRows, minimumWidth: FreeRecordDateWheelLayout.minimumMonthWidth),
                rows: monthRows,
                selectedIndex: monthSelectedIndex
            ) { index in
                guard monthValues.indices.contains(index) else { return }
                updateSelectedDate(month: monthValues[index])
            }

            pickerColumn(
                width: columnWidth(for: dateRows, minimumWidth: FreeRecordDateWheelLayout.minimumDateWidth),
                rows: dateRows,
                selectedIndex: dateSelectedIndex
            ) { index in
                guard selectableDates.indices.contains(index) else { return }
                selectedDate = selectableDates[index]
            }
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

    var yearSelectedIndex: Int {
        let selectedYear = calendar.component(.year, from: selectedDate)
        return yearValues.firstIndex(of: selectedYear) ?? 0
    }

    var monthSelectedIndex: Int {
        let selectedMonth = calendar.component(.month, from: selectedDate)
        return monthValues.firstIndex(of: selectedMonth) ?? 0
    }

    var dateSelectedIndex: Int {
        let normalizedDate = calendar.startOfDay(for: selectedDate)
        return selectableDates.firstIndex {
            calendar.isDate($0, inSameDayAs: normalizedDate)
        } ?? 0
    }

    func pickerColumn(
        width: CGFloat,
        rows: [String],
        selectedIndex: Int,
        onSelect: @escaping (Int) -> Void
    ) -> some View {
        FreeRecordPickerColumn(
            width: width,
            rows: rows,
            selectedIndex: selectedIndex,
            onSelect: onSelect
        )
        .frame(width: width, height: FreeRecordDateWheelLayout.pickerHeight)
        .clipped()
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

    func dateTitle(_ date: Date) -> String {
        let day = calendar.component(.day, from: date)
        let weekday = Self.weekdayFormatter.string(from: date)
        return "\(day)일  \(weekday)"
    }

    func columnWidth(for rows: [String], minimumWidth: CGFloat) -> CGFloat {
        let maxTextWidth = rows
            .map { ($0 as NSString).size(withAttributes: [.font: Typography.headline1Medium.uiFont]).width }
            .max() ?? 0

        return max(minimumWidth, ceil(maxTextWidth) + FreeRecordDateWheelLayout.horizontalTextPadding)
    }

    static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
}

private enum FreeRecordDateWheelLayout {
    static let minimumYearWidth: CGFloat = 80
    static let minimumMonthWidth: CGFloat = 56
    static let minimumDateWidth: CGFloat = 116
    static let componentSpacing: CGFloat = 16
    static let horizontalTextPadding: CGFloat = 24
    static let rowHeight: CGFloat = 34
    static let selectedRowHeight: CGFloat = 32
    static let pickerHeight: CGFloat = 144
}

private struct FreeRecordPickerColumn: UIViewRepresentable {
    let width: CGFloat
    let rows: [String]
    let selectedIndex: Int
    let onSelect: (Int) -> Void

    func makeUIView(context: Context) -> FreeRecordPickerColumnView {
        let columnView = FreeRecordPickerColumnView()
        columnView.pickerView.dataSource = context.coordinator
        columnView.pickerView.delegate = context.coordinator
        return columnView
    }

    func updateUIView(_ columnView: FreeRecordPickerColumnView, context: Context) {
        context.coordinator.parent = self
        columnView.updateSelectionBackground(width: width)
        columnView.pickerView.reloadAllComponents()
        columnView.pickerView.removeSystemSelectionChrome()

        guard rows.indices.contains(selectedIndex) else { return }
        columnView.pickerView.selectRow(selectedIndex, inComponent: 0, animated: false)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: FreeRecordPickerColumn

        init(parent: FreeRecordPickerColumn) {
            self.parent = parent
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            1
        }

        func pickerView(
            _ pickerView: UIPickerView,
            numberOfRowsInComponent component: Int
        ) -> Int {
            parent.rows.count
        }

        func pickerView(
            _ pickerView: UIPickerView,
            rowHeightForComponent component: Int
        ) -> CGFloat {
            FreeRecordDateWheelLayout.rowHeight
        }

        func pickerView(
            _ pickerView: UIPickerView,
            viewForRow row: Int,
            forComponent component: Int,
            reusing view: UIView?
        ) -> UIView {
            let label = (view as? UILabel) ?? UILabel()
            label.textAlignment = .center
            label.font = Typography.headline1Medium.uiFont
            label.textColor = UIColor(Color.gray900)
            label.backgroundColor = .clear
            label.text = parent.rows.indices.contains(row) ? parent.rows[row] : nil
            return label
        }

        func pickerView(
            _ pickerView: UIPickerView,
            didSelectRow row: Int,
            inComponent component: Int
        ) {
            parent.onSelect(row)
        }
    }
}

private final class FreeRecordPickerColumnView: UIView {
    let pickerView = FreeRecordColumnPickerView()

    private let selectionBackgroundView = UIView()
    private var selectionBackgroundWidth: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        selectionBackgroundView.frame = CGRect(
            x: (bounds.width - selectionBackgroundWidth) / 2,
            y: (bounds.height - FreeRecordDateWheelLayout.selectedRowHeight) / 2,
            width: selectionBackgroundWidth,
            height: FreeRecordDateWheelLayout.selectedRowHeight
        )

        pickerView.frame = bounds
    }

    func updateSelectionBackground(width: CGFloat) {
        selectionBackgroundWidth = width
        setNeedsLayout()
    }

    private func setup() {
        backgroundColor = .clear
        clipsToBounds = true

        selectionBackgroundView.backgroundColor = UIColor(Color.gray100)
        selectionBackgroundView.layer.cornerRadius = .radius8
        selectionBackgroundView.layer.masksToBounds = true
        selectionBackgroundView.isUserInteractionEnabled = false

        pickerView.backgroundColor = .clear
        pickerView.clipsToBounds = true

        addSubview(selectionBackgroundView)
        addSubview(pickerView)
    }
}

private final class FreeRecordColumnPickerView: UIPickerView {
    override func layoutSubviews() {
        super.layoutSubviews()
        removeSystemSelectionChrome()
    }
}

private extension UIPickerView {
    func removeSystemSelectionChrome() {
        subviews.forEach { subview in
            guard subview.bounds.height <= 1 else {
                subview.backgroundColor = .clear
                return
            }
            subview.backgroundColor = .clear
            subview.isHidden = true
            subview.alpha = 0
        }
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
