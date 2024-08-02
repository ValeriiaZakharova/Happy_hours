//
//  PlayerView.swift
//  happy_hours
//
//  Created by Valeriia Zakharova on 02.08.2024.
//

import SwiftUI
import ComposableArchitecture

struct PlayView: View {

    @Environment(\.scenePhase)
    private var scenePhase

    @Bindable var store: StoreOf<PlayReducer>
    let urls: [URL]

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(store.currentTime.formatTime())
                    .foregroundStyle(.white)
                    .padding(.trailing, 10)
                ProgressView(value: store.progress)
                    .fixedProgressViewStyle(color: .yellow, height: 5)
                    .padding(.trailing, 10)
                    .padding(.top, 22)
                Text(store.duration.formatTime())
                    .foregroundStyle(.white)
                    .padding(.trailing, 10)
            }
            .frame(height: 48)
            .background(.lightGreen)
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
            HStack(spacing: 20) {
                Button(action: {
                    store.send(.playStepBack)
                }, label: {
                    Image(systemName: "backward.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.black)
                })
                Button(action: {
                    store.send(.skipBackward)
                }, label: {
                    Image(systemName: "gobackward.15")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.black)
                })
                if store.isPlaying {
                    Button(action: {
                        store.send(.pauseAudio)
                    }, label: {
                        Image(systemName: "pause.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.black)
                    })
                } else {
                    Button(action: {
                        if store.isFirstPress {
                            store.send(.setUrls(urls))
                        } else {
                            store.send(.resumeAudio)
                        }
                    }, label: {
                        Image(systemName: "play.circle")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.black)
                    })
                }
                Button(action: {
                    store.send(.skipForward)
                }, label: {
                    Image(systemName: "goforward.15")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.black)
                })
                Button(action: {
                    store.send(.playStepForward)
                }, label: {
                    Image(systemName: "forward.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.black)
                })
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                if store.isPlaying {
                    store.send(.pauseAudio)
                }
            }
        }
        .onDisappear {
            store.send(.stopAudio)
        }
        .onAppear {
//            store.send(.setUrls(urls))
        }
        .alert($store.scope(state: \.alert, action: \.alert))
        .padding(.bottom, 25)
        .background(.lightGreen)
    }
}

#Preview {
    PlayView(store: Store(initialState: PlayReducer.State( urls: [URL(string: "https://chill.mp3")!])) {
        PlayReducer()
    },
             urls: [
                URL(string: "https://chill.mp3")!
             ]
    )
}
