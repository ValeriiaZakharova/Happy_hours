//
//  AudioBookModel.swift
//  happy_hours
//
//  Created by Valeriia Zakharova on 29.07.2024.
//

import SwiftUI

struct Audiobook: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let urlZipFile: String
    let authors: [Author]

    struct Author: Codable, Identifiable, Equatable {
        let id: String
        let firstName: String
        let lastName: String

        enum CodingKeys: String, CodingKey {
            case id
            case firstName = "first_name"
            case lastName = "last_name"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case urlZipFile = "url_zip_file"
        case authors
    }
}

struct LibriVoxResponse: Codable {
    let books: [Audiobook]
}
