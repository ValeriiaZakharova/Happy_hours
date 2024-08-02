//
//  String+.swift
//  happy_hours
//
//  Created by Valeriia Zakharova on 02.08.2024.
//

import Foundation

extension String {
    /// Create an URL from a string. Otherwise, return null
    var asURL: URL? { URL(string: self) }
}

