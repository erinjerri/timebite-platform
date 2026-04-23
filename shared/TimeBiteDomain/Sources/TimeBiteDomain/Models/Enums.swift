import Foundation

public enum ProjectState: String, Codable, CaseIterable, Sendable {
    case active
    case paused
    case deferred
    case blocked
    case archived
}

public enum ProjectType: String, Codable, CaseIterable, Sendable {
    case app
    case income
    case brand
    case support
    case personal
    case other
}

public enum Lane: String, Codable, CaseIterable, Sendable {
    case app
    case income
    case brand
    case support
}
