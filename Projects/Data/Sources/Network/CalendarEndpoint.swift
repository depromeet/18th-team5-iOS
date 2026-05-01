import Alamofire
import Foundation

enum CalendarEndpoint: APIEndpoint {
    case fetchMonthRecords(year: Int, month: Int)
    case fetchDayDetail(date: Date)

    var path: String {
        switch self {
        case .fetchMonthRecords:
            return "/calendar/records"
        case let .fetchDayDetail(date):
            let formatted = ISO8601DateFormatter().string(from: date).prefix(10)
            return "/calendar/records/\(formatted)"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case let .fetchMonthRecords(year, month):
            return [
                URLQueryItem(name: "year", value: "\(year)"),
                URLQueryItem(name: "month", value: "\(month)")
            ]
        case .fetchDayDetail:
            return nil
        }
    }
}
