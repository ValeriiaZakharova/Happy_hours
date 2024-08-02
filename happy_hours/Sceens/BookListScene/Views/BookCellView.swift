//
//  BookCellView.swift
//  happy_hours
//
//  Created by Valeriia Zakharova on 02.08.2024.
//

import SwiftUI

struct BookCellView: View {

    let book: Audiobook

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 20) {
                Text(book.title)
                    .font(.headline)
                Text(book.description)
                    .font(.subheadline)
                    .lineLimit(3)
            }
            .padding(.bottom, 16)
            .padding(.horizontal, 40)
            Divider()
                .background(.white)
        }
    }
}

#Preview {
    BookCellView(book: Audiobook(
        id: "1",
        title: "Infinity Jest",
        description: "Bla Bla",
        urlZipFile: "")
    )
}

