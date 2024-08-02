//
//  BookListView.swift
//  happy_hours
//
//  Created by Valeriia Zakharova on 02.08.2024.
//

import SwiftUI
import ComposableArchitecture

struct BookListView: View {

    @Bindable var store: StoreOf<BookListReducer>

    var body: some View {
        NavigationStack {
            List {
                Text("AudioBooks")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                    .padding(.horizontal, 40)
                    .foregroundColor(.yellow)
                    .listRowBackground(Color.clear)
                    .rowSeparatorsHiddenAdjustInsets()
                ForEach(store.books) { book in
                    // Don't like how NavigationLink could create problems
                    // That's why there is a button
                    Button(action: {
                        store.send(.updateSelectedBook(book))
                    }, label: {
                        BookCellView(book: book)
                            .padding(.top, 20)
                    })
                    .listRowBackground(Color.clear)
                }
                .rowSeparatorsHiddenAdjustInsets()
            }
            .refreshable {
                store.send(.fetchBooks)
            }
            .overlay {
                if !store.isBooksLoaded {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
            .alert($store.scope(state: \.alert, action: \.alert))
            .onAppear {
                store.send(.fetchBooks)
            }
            .fullScreenCover(
                item: $store.scope(state: \.destination?.bookDetails, action: \.destination.bookDetails),
                onDismiss: {
                     store.send(.deleteAllFiles)
                },
                content: { store in
                    NavigationView {
                        BookDetailsView(store: store)
                    }
                })
            .listStyle(.plain)
            .background(.lightGreen)
        }
    }
}

#Preview {
    NavigationStack {
        BookListView(store: Store(initialState: BookListReducer.State(),
                                      reducer: { BookListReducer() }))
    }
}
