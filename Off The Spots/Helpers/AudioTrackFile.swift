//
//  AudioTrackFile.swift
//  Off The Spots
//
//  Created by David Freeman on 10/27/26.
//

import AudioToolbox
import Foundation

enum AudioTrackFile {
    /// Keep the import's extension: changing it doesn't convert the audio bytes.
    static func writeTemporaryFile(data: Data, fileExtension: String?) throws -> URL {
        var url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        if let fileExtension, !fileExtension.isEmpty {
            url.appendPathExtension(fileExtension)
        }
        try data.write(to: url, options: .atomic)

        // Older tracks only stored bytes. Ask Core Audio for their container type.
        if url.pathExtension.isEmpty, let detectedExtension = detectExtension(at: url) {
            let renamedURL = url.appendingPathExtension(detectedExtension)
            do {
                try FileManager.default.moveItem(at: url, to: renamedURL)
                url = renamedURL
            } catch {
                try? FileManager.default.removeItem(at: url)
                throw error
            }
        }
        return url
    }

    private static func detectExtension(at url: URL) -> String? {
        // The MP3 hint also recognizes legacy files with padding before the first
        // MPEG frame, which header-only detection can miss without an extension.
        for hint: AudioFileTypeID in [0, kAudioFileMP3Type] {
            var file: AudioFileID?
            guard AudioFileOpenURL(url as CFURL, .readPermission, hint, &file) == noErr,
                  let file else { continue }
            defer { AudioFileClose(file) }

            var type: AudioFileTypeID = 0
            var size = UInt32(MemoryLayout<AudioFileTypeID>.size)
            guard AudioFileGetProperty(file, kAudioFilePropertyFileFormat, &size, &type) == noErr else {
                continue
            }
            switch type {
            case kAudioFileMP3Type: return "mp3"
            case kAudioFileWAVEType: return "wav"
            case kAudioFileAIFFType: return "aiff"
            case kAudioFileAIFCType: return "aifc"
            case kAudioFileM4AType: return "m4a"
            case kAudioFileMPEG4Type: return "mp4"
            case kAudioFileAAC_ADTSType: return "aac"
            case kAudioFileCAFType: return "caf"
            case kAudioFileFLACType: return "flac"
            default: return nil
            }
        }
        return nil
    }
}
