//
//  FixedProgressView.swift
//  happy_hours
//
//  Created by Valeriia Zakharova on 02.08.2024.
//

import SwiftUI

struct FixedProgressViewStyle: ProgressViewStyle {

    let color: Color
    let height: CGFloat

    func makeBody(configuration: Configuration) -> some View {

        let progress = configuration.fractionCompleted ?? 0.0

        GeometryReader { geometry in
            VStack(alignment: .leading) {
                Rectangle()
                    .fill(.white)
                    .frame(height: height)
                    .frame(width: geometry.size.width)
                    .cornerRadius(5)
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(color)
                            .cornerRadius(5)
                            .frame(width: geometry.size.width * progress)
                    }
            }
        }
    }
}

extension View {

    /// The function returns progress view style with given color and height
    /// - Parameters:
    ///   - color: A color for progress bar
    ///   - height: A height of the progress bar
    /// - Returns: Progress view style
    func fixedProgressViewStyle(color: Color, height: CGFloat) -> some View {
        progressViewStyle(FixedProgressViewStyle(color: color, height: height))
    }
}
