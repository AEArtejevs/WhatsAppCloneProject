//
//  MessageInputView.swift
//  WhatsAppClone
//
//  Created by Andris on 27/04/2026.
//

import SwiftUI
import Speech
import AVFoundation
import Combine

struct MessageInput: View {
    @Binding var messageText: String

    let isSending: Bool
    let onSend: () -> Void

    @StateObject private var speechManager = SpeechToTextManager()

    private var trimmedMessage: String {
        messageText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        HStack(spacing: 10) {
            TextField("Message", text: $messageText)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .frame(minHeight: 36)
                .disabled(isSending || speechManager.isRecording)

            if trimmedMessage.isEmpty {
                Button {
                    speechManager.toggleRecording { recognizedText in
                        messageText = recognizedText
                    }
                } label: {
                    Image(systemName: speechManager.isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.white)
                        .frame(width: 36, height: 36)
                        .background(speechManager.isRecording ? Color.red : Color.blue)
                        .clipShape(Circle())
                }
                .disabled(isSending)
            } else {
                Button {
                    onSend()
                } label: {
                    Image(systemName: isSending ? "hourglass" : "paperplane.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.white)
                        .frame(width: 36, height: 36)
                        .background(isSending ? Color.gray : Color.blue)
                        .clipShape(Circle())
                }
                .disabled(isSending)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.clear)
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
}

#Preview {
    MessageInput(
        messageText: .constant("Hello"),
        isSending: false
    ) {
        print("Send tapped")
    }
}

@MainActor
final class SpeechToTextManager: ObservableObject {
    @Published var isRecording: Bool = false

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    func toggleRecording(onTextRecognized: @escaping (String) -> Void) {
        if isRecording {
            stopRecording()
            return
        }

        requestPermissions { [weak self] isAllowed in
            guard let self else {
                return
            }

            if isAllowed {
                self.startRecording(onTextRecognized: onTextRecognized)
            } else {
                print("Microphone or speech recognition permission denied")
            }
        }
    }

    private func requestPermissions(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { speechStatus in
            AVAudioSession.sharedInstance().requestRecordPermission { microphoneAllowed in
                DispatchQueue.main.async {
                    let speechAllowed = speechStatus == .authorized
                    completion(speechAllowed && microphoneAllowed)
                }
            }
        }
    }

    private func startRecording(onTextRecognized: @escaping (String) -> Void) {
        stopRecording()

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard let recognitionRequest else {
            print("Could not create speech recognition request")
            return
        }

        recognitionRequest.shouldReportPartialResults = true

        let audioSession = AVAudioSession.sharedInstance()

        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session setup failed: \(error.localizedDescription)")
            return
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            print("Audio engine failed to start: \(error.localizedDescription)")
            stopRecording()
            return
        }

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result {
                let text = result.bestTranscription.formattedString

                DispatchQueue.main.async {
                    onTextRecognized(text)
                }
            }

            if error != nil {
                DispatchQueue.main.async {
                    self.stopRecording()
                }
            }
        }
    }

    private func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }

        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false

        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session cleanup failed: \(error.localizedDescription)")
        }
    }
}
