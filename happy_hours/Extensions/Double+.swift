//
//  Double+.swift
//  happy_hours
//
//  Created by Valeriia Zakharova on 02.08.2024.
//

import Foundation

extension Double {

    /// This function convert Double into a formatted String
    /// - Returns: Formatted string minutes:seconds
    func formatTime() -> String {
        let duration = Int(self)
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
