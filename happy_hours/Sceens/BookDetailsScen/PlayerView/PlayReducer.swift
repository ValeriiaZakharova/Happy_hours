//
//  PlayReducer.swift
//  happy_hours
//
//  Created by Valeriia Zakharova on 02.08.2024.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct PlayReducer {

    @ObservableState
    struct State: Equatable {
        var duration: Double = 0.0
        var progress: Double = 0.0
        var currentTime: Double = 0.0
        var isPlaying = false
        var isFirstPress = true
        var isNext = false
        var urls: [URL]
        @Presents var alert: AlertState<Action.Alert>?
    }

    enum Action: BindableAction {
        case setUrls([URL])
        case getDuration(URL?)
        case updateDuration(Double)
        case playAudio
        case pauseAudio
        case resumeAudio
        case playStepForward
        case playStepBack
        case skipForward
        case skipBackward
        case updateProgress
        case resetPlayer
        case updateIsPlayingState
        case toggleTimer
        case stopAudio
        case failed(Error)
        case showErrorAlert(message: String)
        case alert(PresentationAction<Alert>)
        case binding(BindingAction<State>)

        @CasePathable
        enum Alert {
            case tryAgainButtonTapped
            case okButtonTapped
        }
    }

    enum CancelID {
        case timer
    }

    @Dependency(\.audioPlayer)
    private var audioPlayer

    @Dependency(\.uRLManager)
    private var uRLManager

    @Dependency(\.continuousClock)
    private var clock

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .setUrls(let urls):
                uRLManager.addURLs(urls)
                return .send(.getDuration(uRLManager.firstURL()))
            case .getDuration(let url):
                return .run { send in
                    let duration = audioPlayer.getAudioFileDuration(url: url).toDouble
                    await send(.updateDuration(duration))
                }
            case .updateDuration(let duration):
                state.duration = duration
                return .send(.playAudio)
            case .playAudio:
                return playAudio(from: uRLManager.firstURL())
            case .updateIsPlayingState:
                if !state.isNext {
                    state.isFirstPress.toggle()
                    state.isPlaying.toggle()
                }
                return .send(.toggleTimer)
            case .toggleTimer:
                return .run { send in
                    for await _ in clock.timer(interval: .seconds(1)) {
                        await send(.updateProgress)
                    }
                }
                .cancellable(id: CancelID.timer)
            case .updateProgress:
                state.progress = audioPlayer.progress
                state.currentTime = audioPlayer.currentTime
                if audioPlayer.state == .stopped {
                    return .send(.resetPlayer)
                }
                return .none
            case .resetPlayer:
                state.isPlaying.toggle()
                state.isFirstPress.toggle()
                state.progress = 0.0
                state.isNext.toggle()
                return .cancel(id: CancelID.timer)
            case .pauseAudio:
                audioPlayer.pause()
                state.isPlaying.toggle()
                return .cancel(id: CancelID.timer)
            case .resumeAudio:
                state.isPlaying.toggle()
                audioPlayer.resume()
                return .send(.toggleTimer)
            case .stopAudio:
                audioPlayer.stop()
                return .cancel(id: CancelID.timer)
            case .playStepForward:
                state.isNext = true
                return playAudio(from: uRLManager.nextURL())
            case .playStepBack:
                state.isNext = true
                return playAudio(from: uRLManager.previousURL())
            case .skipForward:
                return skipForward()
            case .skipBackward:
                return skipBackward()
            case .failed(let error):
                return handleErrorTask(error)
            case .showErrorAlert(let message):
                state.alert = AlertState {
                    TextState("Oops, something went wrong")
                } actions: {
                    ButtonState(action: .tryAgainButtonTapped) {
                        TextState("Try Again")
                    }
                    ButtonState(action: .okButtonTapped) {
                        TextState("OK")
                    }
                } message: {
                    TextState(message)
                }
                return .none
            case .alert(.presented(.tryAgainButtonTapped)):
                return .send(.playAudio)
            case .alert(.presented(.okButtonTapped)):
                return .none
            case .alert:
                return .none
            case .binding:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

private extension PlayReducer {

    func playAudio(from url: URL?) -> Effect<Action> {
        do {
            try audioPlayer.play(url: url)
            return .send(.updateIsPlayingState)
        } catch {
            return .send(.failed(error))
        }
    }

    func skipForward() -> Effect<Action> {
        do {
            audioPlayer.skipForward15Seconds()
            return .send(.updateProgress)
        }
    }

    func skipBackward() -> Effect<Action> {
        do {
            audioPlayer.skipBackward15Seconds()
            return .send(.updateProgress)
        }
    }

    func handleErrorTask(_ error: Error) -> Effect<Action> {
        if let happyError = error as? HappyHoursError,
           let errorDescription = happyError.errorDescription {
            return .send(.showErrorAlert(message: errorDescription))
        }
        return .send(.showErrorAlert(message: error.localizedDescription))
    }
}
