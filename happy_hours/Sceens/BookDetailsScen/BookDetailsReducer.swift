//
//  BookDetailsReducer.swift
//  happy_hours
//
//  Created by Valeriia Zakharova on 02.08.2024.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct BookDetailsReducer {

    @ObservableState
    struct State: Equatable {
        var book: Audiobook
        var audioURLs: [URL] = []
        var isBookLoaded = false
        var keyPoints: String {
            "There are \(audioURLs.count) different version of this book"
        }
        @Presents var alert: AlertState<Action.Alert>?
    }

    enum Action: BindableAction {
        case fetchAudioBooks
        case updateAudios([URL])
        case failed(Error)
        case showErrorAlert(message: String)
        case deleteAllFiles
        case setIsBookLoaded
        case dismiss
        case alert(PresentationAction<Alert>)
        case binding(BindingAction<BookDetailsReducer.State>)

        @CasePathable
        enum Alert {
            case tryAgainButtonTapped
            case okButtonTapped
        }
    }

    @Dependency(\.bookDetailsService)
    private var bookDetailsService

    @Dependency(\.audioFileManager)
    private var audioFileManager

    @Dependency(\.dismiss)
    private var dismiss

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .fetchAudioBooks:
                return fetchAudioBooksTask(with: state.book.urlZipFile)
            case .updateAudios(let audioUrls):
                state.audioURLs = audioUrls
                return .send(.setIsBookLoaded)
            case .setIsBookLoaded:
                state.isBookLoaded = true
                return .none
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
                return .send(.fetchAudioBooks)
            case .alert(.presented(.okButtonTapped)):
                return .none
            case .deleteAllFiles:
                return delete()
            case .binding:
                return .none
            case .alert:
                return .none
            case .dismiss:
                return .run { _ in
                    await dismiss()
                }
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

private extension BookDetailsReducer {

    func fetchAudioBooksTask(with zipUrl: String) -> Effect<Action> {
        .run { send in
            let audiosURL = try await bookDetailsService.downloadAndUnzipAudioBooks(from: zipUrl)
            await send(.updateAudios(audiosURL))
        } catch: { error, send in
            await send(.failed(error))
        }
    }

    func delete() -> Effect<Action> {
        .run { send in
            try audioFileManager.deleteAllFiles()
        } catch: { error, send in
            await send(.failed(error))
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
