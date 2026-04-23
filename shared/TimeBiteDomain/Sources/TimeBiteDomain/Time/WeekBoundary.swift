import Foundation

public enum WeekBoundary {
    public static func weekInterval(containing date: Date, calendar: Calendar = .current) -> DateInterval? {
        calendar.dateInterval(of: .weekOfYear, for: date)
    }
}

