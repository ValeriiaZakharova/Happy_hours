//
//  NetworkingService.swift
//  happy_hours
//
//  Created by Valeriia Zakharova on 02.08.2024.
//

import SwiftUI
import Dependencies

final class NetworkingService {

    private let session = URLSession.shared

    func fetchData<T: Decodable>(endpoint: String) async throws -> T {
        guard let url = URL(string: endpoint) else {
            throw HappyHoursError.invalidURL
        }

        let (data, _) = try await session.data(from: url)
        let decodedData = try JSONDecoder().decode(T.self, from: data)
        return decodedData
    }

    func downloadFile(from url: URL) async throws -> URL {
        let (localURL, _) = try await session.download(from: url)
        return localURL
    }
}
