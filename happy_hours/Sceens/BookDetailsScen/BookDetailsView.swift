//
//  BookDetailsView.swift
//  happy_hours
//
//  Created by Valeriia Zakharova on 02.08.2024.
//

import SwiftUI
import ComposableArchitecture
import Combine

struct BookDetailsView: View {

    @Bindable var store: StoreOf<BookDetailsReducer>

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text(store.book.title)
                    .font(.largeTitle)
                    .padding(.top, 10)
                    .padding(.horizontal, 40)
                    .foregroundColor(.black)
                Text(store.book.description)
                    .font(.title3)
                    .padding(.top, 10)
                    .padding(.horizontal, 40)
                    .foregroundColor(.black)
                Spacer()
                Text(store.keyPoints)
                    .padding(.horizontal, 80)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                PlayView(
                    store: Store(initialState: PlayReducer.State(urls: store.audioURLs),
                    reducer: { PlayReducer()
                    }),
                    urls: store.audioURLs)
                Spacer()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    store.send(.dismiss)
                }, label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .padding(.trailing, 20)
                })
            }
        }
        .overlay {
            if !store.isBookLoaded {
                LoadingAnimationView()
            }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
        .onAppear {
            store.send(.fetchAudioBooks)
        }
        .onDisappear {
            store.send(.deleteAllFiles)
        }
        .listStyle(.plain)
        .background(.lightGreen)
    }
}

#Preview {
    NavigationStack {
        BookDetailsView(store: Store(initialState: BookDetailsReducer.State(book: Audiobook(
            id: "",
            title: "Happy Hours",
            description: "This story is set in the British province of New York during the French and Indian War, and concerns a Huron massacre (with passive French acquiescence) of from 500 to 1,500 unarmed Anglo-American troops, who had honorably surrendered at Fort William Henry",
            urlZipFile: "")),
                                      reducer: { BookDetailsReducer() }))
    }
}

