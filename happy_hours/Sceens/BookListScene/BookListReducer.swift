//
//  BookListReducer.swift
//  happy_hours
//
//  Created by Valeriia Zakharova on 02.08.2024.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct BookListReducer {

    @Reducer(state: .equatable)
    enum Destination {
        case bookDetails(BookDetailsReducer)
    }

    @ObservableState
    struct State: Equatable {
        var books: [Audiobook] = []
        var selectedBook: Audiobook = Audiobook(id: "", title: "", description: "", urlZipFile: "")
        var isBooksLoaded = false
        @Presents var alert: AlertState<Action.Alert>?
        @Presents var destination: Destination.State?
    }

    enum Action: BindableAction {
        case fetchBooks
        case updateBooks([Audiobook])
        case deleteAllFiles
        case failed(Error)
        case showErrorAlert(message: String)
        case updateSelectedBook(Audiobook)
        case presentBookDetailsView
        case alert(PresentationAction<Alert>)
        case binding(BindingAction<BookListReducer.State>)
        case destination(PresentationAction<Destination.Action>)

        @CasePathable
        enum Alert {
            case tryAgainButtonTapped
            case okButtonTapped
        }
    }

    @Dependency(\.bookService)
    private var bookService
    
    @Dependency(\.audioFileManager)
    private var audioFileManager

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .fetchBooks:
                return fetchRecordingsTask()
            case .updateBooks(let books):
                state.isBooksLoaded.toggle()
                state.books = books
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
                return .send(.fetchBooks)
            case .alert(.presented(.okButtonTapped)):
                return .none
            case .updateSelectedBook(let book):
                state.selectedBook = book
                return .send(.presentBookDetailsView)
            case .presentBookDetailsView:
                state.destination = .bookDetails(BookDetailsReducer.State(book: state.selectedBook))
                return .none
            case .deleteAllFiles:
                return delete()
            case .binding:
                return .none
            case .alert:
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
        .ifLet(\.$destination, action: \.destination)
    }
}

private extension BookListReducer {

    func fetchRecordingsTask() -> Effect<Action> {
        .run { send in
            let booksResponse = try await bookService.fetchAudioBooks()
            // Filtering response to choose the most short books to be able to download it faster
            let filteredBooks = booksResponse.books.filter { ["121", "89", "80", "127"].contains($0.id) }
            await send(.updateBooks(filteredBooks))
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
