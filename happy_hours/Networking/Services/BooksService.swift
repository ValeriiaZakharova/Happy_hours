//
//  BooksService.swift
//  happy_hours
//
//  Created by Valeriia Zakharova on 02.08.2024.
//

import Foundation
import Dependencies

protocol BooksServiceProtocol {
    func fetchAudioBooks() async throws -> LibriVoxResponse
}

final class BookService: BooksServiceProtocol {

    private enum Constants {
        static let baseUrl = "https://librivox.org/api/feed/audiobooks?format=json"
    }

    let service: NetworkingService

    init(service: NetworkingService) {
        self.service = service
    }

    @MainActor
    func fetchAudioBooks() async throws -> LibriVoxResponse {
        do {
            let response: LibriVoxResponse = try await service.fetchData(endpoint: Constants.baseUrl)
            return response
        } catch {
            throw handleError(error)
        }
    }

    private func handleError(_ error: Error) -> HappyHoursError {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return .noInternetConnection
            case .timedOut:
                return .timeout
            case .badURL:
                return .invalidURL
            default:
                return .generic
            }
        }

        if let urlResponseError = error as? HTTPURLResponse {
            switch urlResponseError.statusCode {
            case 401, 403, 404, 500:
                return .serverError
            default:
                return .generic
            }
        }

        if let decodingError = error as? DecodingError {
            return .decodingError
        }

        return .generic
    }
}

extension BookService: DependencyKey {
    static let liveValue: any BooksServiceProtocol = BookService(
        service: NetworkingService()
    )
}

extension DependencyValues {
    var bookService: BooksServiceProtocol {
        get { self[BookService.self] }
        set { self[BookService.self] = newValue }
    }
}
