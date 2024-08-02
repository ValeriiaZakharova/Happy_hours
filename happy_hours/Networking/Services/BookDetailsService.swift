//
//  BookDetailsService.swift
//  happy_hours
//
//  Created by Valeriia Zakharova on 02.08.2024.
//

import Foundation
import SwiftUI
import Dependencies

protocol BookDetailServiceProtocol {
    func downloadAndUnzipAudioBooks(from zipURL: String) async throws -> [URL]
}

final class BookDetailsService: BookDetailServiceProtocol {
    
    private enum Constants {
        static let destinationDirectoryName = "audiobooks"
    }

    private let service: NetworkingService

    init(service: NetworkingService) {
        self.service = service
    }

    @Dependency(\.audioFileManager)
    private var audioFileManager: AudioFileManager

    @MainActor
    func downloadAndUnzipAudioBooks(from zipURL: String) async throws -> [URL] {
        guard let zipURL = zipURL.asURL else {
            throw HappyHoursError.invalidURL
        }

        do {
            let localURL = try await service.downloadFile(from: zipURL)

            try audioFileManager.unzip(zipURL: localURL)

            let audioFiles = audioFileManager.listAudioFiles()
            return audioFiles
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

        return .generic
    }
}

extension BookDetailsService: DependencyKey {
    static let liveValue: any BookDetailServiceProtocol = BookDetailsService(
        service: NetworkingService()
    )
}

extension DependencyValues {
    var bookDetailsService: BookDetailServiceProtocol {
        get { self[BookDetailsService.self] }
        set { self[BookDetailsService.self] = newValue }
    }
}
