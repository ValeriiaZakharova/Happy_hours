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
        let circleDiameter = height * 2

        GeometryReader { geometry in
            VStack(alignment: .leading) {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white)
                        .frame(height: height)
                        .cornerRadius(5)
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: height)
                        .cornerRadius(5)
                    Circle()
                        .fill(color)
                        .frame(width: circleDiameter, height: circleDiameter)
                        .offset(x: geometry.size.width * progress - circleDiameter / 2)
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
