//
//  AudioFileManager.swift
//  happy_hours
//
//  Created by Valeriia Zakharova on 02.08.2024.
//

import SwiftUI
import Dependencies
import ZIPFoundation

final class AudioFileManager {

    private enum Constants {
        static let directoryName = "AudioFiles"
    }

    private let fileManager = FileManager.default

    /// Creates and returns the URL for the directory where audio files will be stored
    func audioFilesDirectoryURL() -> URL {
        let directoryURL = fileManager.temporaryDirectory.appendingPathComponent(Constants.directoryName)
        
        // Ensure the directory exists
        if !fileManager.fileExists(atPath: directoryURL.path) {
            do {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Failed to create directory: \(error.localizedDescription)")
            }
        }
        
        return directoryURL
    }

    /// Lists all audio files in the directory
    /// - Returns: Array of URLs of audio files
    func listAudioFiles() -> [URL] {
        let directoryURL = audioFilesDirectoryURL()

        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            return fileURLs.filter { $0.pathExtension == "mp3" || $0.pathExtension == "m4a" }
        } catch {
            print("Failed to list files: \(error.localizedDescription)")
            return []
        }
    }

    /// Unzips a ZIP file into the audio files directory
    /// - Parameter zipURL: URL of the ZIP file to unzip
    /// - Throws: An error if the unzip operation fails
    func unzip(zipURL: URL) throws {
        let destinationURL = audioFilesDirectoryURL()

        if !fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
        }

        try fileManager.unzipItem(at: zipURL, to: destinationURL)
    }

    /// Deletes the entire audio files directory
    /// - Throws: An error if the directory cannot be deleted
    func deleteAllFiles() throws {
        let directoryURL = audioFilesDirectoryURL()

        do {
            try fileManager.removeItem(at: directoryURL)
        } catch {
            print("Failed to delete directory: \(error.localizedDescription)")
        }
    }
}

extension AudioFileManager: DependencyKey {
    static let liveValue = AudioFileManager()
}

extension DependencyValues {
    var audioFileManager: AudioFileManager {
        get { self[AudioFileManager.self] }
        set { self[AudioFileManager.self] = newValue }
    }
}
