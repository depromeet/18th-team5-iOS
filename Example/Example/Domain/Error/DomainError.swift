import Foundation

enum DomainError: Error, Equatable {
    case unauthorized
    case forbidden
    case notFound
    case invalidRequest(String?)
    case serviceUnavailable
    case dataCorrupted
    case serverError
    case unknown(String)
}
