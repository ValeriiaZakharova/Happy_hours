//
//  NetworkError.swift
//  happy_hours
//
//  Created by Valeriia Zakharova on 02.08.2024.
//

import Foundation

enum HappyHoursError: Error, Equatable {
    case noInternetConnection
    case invalidURL
    case serverError
    case timeout
    case decodingError
    case playerError
    case generic

    var errorDescription: String? {
        switch self {
        case .noInternetConnection:
            return "No internet connection"
        case .invalidURL:
            return "Sorry, the URL is not valid"
        case .serverError:
            return "Server error occurred"
        case .timeout:
            return "The request timed out"
        case .decodingError:
            return "Failed to decode response"
        case .generic:
            return "An unexpected error occurred"
        case .playerError:
            return "Player setup failed"
        }
    }
}
