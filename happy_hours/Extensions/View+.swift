//
//  View+.swift
//  happy_hours
//
//  Created by Valeriia Zakharova on 02.08.2024.
//


import SwiftUI

extension View {

    /// Hides the separator lines between rows in a List and adjusts row insets
    /// - Returns: A view modified to hide separator lines and adjust row insets
    func rowSeparatorsHiddenAdjustInsets() -> some View {
        self.listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
    }
}

