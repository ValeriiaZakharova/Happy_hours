//
//  URLManager.swift
//  happy_hours
//
//  Created by Valeriia Zakharova on 02.08.2024.
//
import SwiftUI
import Dependencies

final class URLManager {
    private var urls: [URL] = []
    private var currentURL: URL?

    func addURLs(_ newURLs: [URL]) {
        urls = newURLs
        currentURL = urls.first
    }

    // Moves to the next URL in the list
    func nextURL() -> URL? {
        guard let current = currentURL,
              let currentIndex = urls.firstIndex(of: current),
              currentIndex + 1 < urls.count else { return nil }
        currentURL = urls[currentIndex + 1]
        return currentURL
    }

    // Moves to the previous URL in the list
    func previousURL() -> URL? {
        guard let current = currentURL,
              let currentIndex = urls.firstIndex(of: current),
              currentIndex - 1 >= 0 else { return nil }
        currentURL = urls[currentIndex - 1]
        return currentURL
    }

    // Returns the first URL in the list
    func firstURL() -> URL? {
        currentURL = urls.first
        return currentURL
    }
}

extension URLManager: DependencyKey {
    static let liveValue = URLManager()
}

extension DependencyValues {
    var uRLManager: URLManager {
        get { self[URLManager.self] }
        set { self[URLManager.self] = newValue }
    }
}

