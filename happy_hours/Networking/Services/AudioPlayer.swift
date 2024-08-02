//
//  AudioPlayer.swift
//  happy_hours
//
//  Created by Valeriia Zakharova on 02.08.2024.
//

import SwiftUI
import Dependencies
import AVFoundation

enum AudioPlayerState {
    case none
    case playing
    case paused
    case stopped
}

final class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    private enum Constants {
        static let time: Double = 15
    }
    private var audioPlayer: AVAudioPlayer?
    private(set) var state: AudioPlayerState = .none

    var progress: Double {
        guard let player = audioPlayer else { return 0.0 }
        return player.currentTime / player.duration
    }

    var duration: Double {
        guard let player = audioPlayer else { return 0.0 }
        return player.duration
    }

    var currentTime: Double {
        guard let player = audioPlayer else { return 0.0 }
        return player.currentTime
    }

    func play(url: URL?) throws {
        // Stops any current playback
        stop()

        guard let url else {
            state = .none
            return
        }

        configureAudioSession()
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self 
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            state = .playing
        } catch {
            state = .none
            throw HappyHoursError.playerError
        }
    }

    func pause() {
        audioPlayer?.pause()
        state = .paused
    }

    func resume() {
        audioPlayer?.play()
        state = .playing
    }

    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        state = .stopped
    }

    func skipForward15Seconds() {
        guard let player = audioPlayer else { return }
        let newTime = player.currentTime + Constants.time
        player.currentTime = min(newTime, player.duration)
    }

    func skipBackward15Seconds() {
        guard let player = audioPlayer else { return }
        let newTime = player.currentTime - Constants.time
        player.currentTime = max(newTime, .zero)
    }

    func getAudioFileDuration(url: URL?) -> Int {
        guard let url = url else {
            return .zero
        }
        do {
            let tempPlayer = try AVAudioPlayer(contentsOf: url)
            return Int(tempPlayer.duration)
        } catch {
            return .zero
        }
    }

    /// Configures session for playback
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("\(error)")
        }
    }

    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        state = .stopped
    }
}

extension AudioPlayer: DependencyKey {
    static let liveValue = AudioPlayer()
}

extension DependencyValues {
    var audioPlayer: AudioPlayer {
        get { self[AudioPlayer.self] }
        set { self[AudioPlayer.self] = newValue }
    }
}
