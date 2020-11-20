import Foundation
import JTAppleCalendar

enum CalendarCollectionViewStyle {
    case month
    case year
}

class CalendarCollectionView: JTACMonthView {

    let calDataSource: CalendarDataSource
    let style: CalendarCollectionViewStyle

    init(calendar: Calendar, style: CalendarCollectionViewStyle = .month) {
        calDataSource = CalendarDataSource(calendar: calendar, style: style)

        self.style = style
        super.init()

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        calDataSource = CalendarDataSource(calendar: Calendar.current, style: .month)
        style = .month
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        register(DateCell.self, forCellWithReuseIdentifier: DateCell.Constants.reuseIdentifier)
        register(CalendarYearHeaderView.self,
                              forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                              withReuseIdentifier: CalendarYearHeaderView.reuseIdentifier)

        backgroundColor = .clear

        switch style {
        case .month:
            scrollDirection = .horizontal
            scrollingMode = .stopAtEachCalendarFrame
        case .year:
            scrollDirection = .vertical

            allowsMultipleSelection = true
            allowsRangedSelection = true
            rangeSelectionMode = .continuous

            minimumLineSpacing = 0
            minimumInteritemSpacing = 0

            cellSize = 50
        }

        showsHorizontalScrollIndicator = false
        isDirectionalLockEnabled = true

        calendarDataSource = calDataSource
        calendarDelegate = calDataSource
    }
}

class CalendarDataSource: JTACMonthViewDataSource {

    var willScroll: ((DateSegmentInfo) -> Void)?
    var didScroll: ((DateSegmentInfo) -> Void)?
    var didSelect: ((Date, Date?) -> Void)?
    var didDeselectAllDates: (() -> Void)?

    // First selected date
    var firstDate: Date?

    private let calendar: Calendar
    private let style: CalendarCollectionViewStyle

    init(calendar: Calendar, style: CalendarCollectionViewStyle) {
        self.calendar = calendar
        self.style = style
    }

    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let startDate = Date.farPastDate
        let endDate = Date.farFutureDate
        return ConfigurationParameters(startDate: startDate, endDate: endDate, calendar: self.calendar)
    }
}

extension CalendarDataSource: JTACMonthViewDelegate {
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: DateCell.Constants.reuseIdentifier, for: indexPath)
        if let dateCell = cell as? DateCell {
            configure(cell: dateCell, with: cellState)
        }
        return cell
    }

    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configure(cell: cell, with: cellState)
    }

    func calendar(_ calendar: JTACMonthView, willScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        willScroll?(visibleDates)
    }

    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        didScroll?(visibleDates)
    }

    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        if style == .year, let firstDate = firstDate {
            calendar.selectDates(from: firstDate,
                                 to: date,
                                 triggerSelectionDelegate: false,
                                 keepSelectionIfMultiSelectionAllowed: true)
            didSelect?(firstDate, date)
        } else {
            firstDate = date
            didSelect?(date, nil)
        }

        configure(cell: cell, with: cellState)
    }

    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        configure(cell: cell, with: cellState)
    }

    func calendar(_ calendar: JTACMonthView, shouldSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool {
        if style == .year, calendar.selectedDates.count > 1 && cellState.selectionType != .programatic || firstDate != nil && !calendar.selectedDates.isEmpty && date < calendar.selectedDates[0] {
            firstDate = nil
            let retval = !calendar.selectedDates.contains(date)
            didDeselectAllDates?()
            calendar.deselectAllDates()
            return retval
        }
        return true
    }

    func calendar(_ calendar: JTACMonthView, shouldDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) -> Bool {
        if style == .year, calendar.selectedDates.count > 1 && cellState.selectionType != .programatic {
            firstDate = nil
            calendar.deselectAllDates()
            didDeselectAllDates?()
            return false
        }

        didDeselectAllDates?()

        return true
    }

    func calendarSizeForMonths(_ calendar: JTACMonthView?) -> MonthSize? {
        return style == .year ? MonthSize(defaultSize: 50) : nil
    }

    func calendar(_ calendar: JTACMonthView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTACMonthReusableView {
        let date = range.start
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM YYYY"
        let header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: CalendarYearHeaderView.reuseIdentifier, for: indexPath)
        (header as! CalendarYearHeaderView).titleLabel.text = formatter.string(from: date)
        return header
    }

    private func configure(cell: JTACDayCell?, with state: CellState) {
        let cell = cell as? DateCell
        cell?.configure(with: state, hideInOutDates: style == .year)
    }
}

class DateCell: JTACDayCell {

    struct Constants {
        static let labelSize: CGFloat = 28
        static let reuseIdentifier = "dateCell"
        static var selectedColor: UIColor {
            UIColor(
                light: UIColor(red: 0.91, green: 0.94, blue: 0.96, alpha: 1.00),
                dark: UIColor(red: 0.02, green: 0.22, blue: 0.35, alpha: 1.00)
            )
        }
    }

    let dateLabel = UILabel()
    let leftPlaceholder = UIView()
    let rightPlaceholder = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.textAlignment = .center
        dateLabel.font = UIFont.preferredFont(forTextStyle: .callout)

        // Show circle behind text for selected day
        dateLabel.clipsToBounds = true
        dateLabel.layer.cornerRadius = Constants.labelSize/2

        addSubview(dateLabel)

        NSLayoutConstraint.activate([
            dateLabel.widthAnchor.constraint(equalToConstant: Constants.labelSize),
            dateLabel.heightAnchor.constraint(equalTo: dateLabel.widthAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            dateLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])

        leftPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        rightPlaceholder.translatesAutoresizingMaskIntoConstraints = false

        addSubview(leftPlaceholder)
        addSubview(rightPlaceholder)

        NSLayoutConstraint.activate([
            leftPlaceholder.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6),
            leftPlaceholder.heightAnchor.constraint(equalTo: dateLabel.heightAnchor),
            leftPlaceholder.rightAnchor.constraint(equalTo: centerXAnchor),
            leftPlaceholder.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            rightPlaceholder.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
            rightPlaceholder.heightAnchor.constraint(equalTo: dateLabel.heightAnchor),
            rightPlaceholder.leftAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            rightPlaceholder.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        bringSubviewToFront(dateLabel)
    }
}

extension DateCell {
    func configure(with state: CellState, hideInOutDates: Bool = false) {

        dateLabel.text = state.text

        let textColor: UIColor

        if hideInOutDates && state.dateBelongsTo != .thisMonth {
            isHidden = true
        } else {
            isHidden = false
        }

        switch state.selectedPosition() {
        case .middle:
            textColor = .text
            leftPlaceholder.backgroundColor = Constants.selectedColor
            rightPlaceholder.backgroundColor = Constants.selectedColor
            dateLabel.backgroundColor = .clear
        case .left:
            textColor = .white
            dateLabel.backgroundColor = WPStyleGuide.wordPressBlue()
            rightPlaceholder.backgroundColor = Constants.selectedColor
        case .right:
            textColor = .white
            dateLabel.backgroundColor = WPStyleGuide.wordPressBlue()
            leftPlaceholder.backgroundColor = Constants.selectedColor
        case .full:
            textColor = .textInverted
            leftPlaceholder.backgroundColor = .clear
            rightPlaceholder.backgroundColor = .clear
            dateLabel.backgroundColor = WPStyleGuide.wordPressBlue()
        case .none:
            leftPlaceholder.backgroundColor = .clear
            rightPlaceholder.backgroundColor = .clear
            dateLabel.backgroundColor = .clear
            if state.dateBelongsTo == .thisMonth {
              textColor = .text
            } else {
              textColor = .textSubtle
            }
        }

        dateLabel.textColor = textColor
    }
}

// MARK: - Year Header View
class CalendarYearHeaderView: JTACMonthReusableView {
    static let reuseIdentifier = "CalendarYearHeaderView"

    let titleLabel: UILabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        pinSubviewToSafeArea(titleLabel, insets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        titleLabel.font = .preferredFont(forTextStyle: .headline)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
