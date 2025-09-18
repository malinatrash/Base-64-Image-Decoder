import SwiftUI
import AVKit

struct AudioPreview: View {
    let data: Data
    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var progress: Double = 0
    @State private var duration: Double = 0
    @State private var currentTime: Double = 0
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 16) {
            // Audio visualization or icon
            Image(systemName: "waveform")
                .font(.system(size: 40))
                .foregroundColor(.accentColor)
            
            // Playback controls
            HStack(spacing: 24) {
                Button(action: seekBackward) {
                    Image(systemName: "gobackward.10")
                        .font(.title2)
                }
                
                Button(action: togglePlayback) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                }
                
                Button(action: seekForward) {
                    Image(systemName: "goforward.10")
                        .font(.title2)
                }
            }
            .foregroundColor(.accentColor)
            
            // Progress bar
            VStack(spacing: 4) {
                Slider(value: $progress, in: 0...1) { editing in
                    if !editing, let player = player {
                        let newTime = progress * player.duration
                        player.currentTime = newTime
                    }
                }
                .accentColor(.accentColor)
                .onReceive(timer) { _ in
                    guard let player = player else { return }
                    currentTime = player.currentTime
                    progress = player.duration > 0 ? player.currentTime / player.duration : 0
                    
                    if !player.isPlaying {
                        isPlaying = false
                    }
                }
                
                HStack {
                    Text(formatTime(currentTime))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(formatTime(duration - currentTime))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .onAppear {
            setupAudioPlayer()
        }
        .onDisappear {
            player?.stop()
            timer.upstream.connect().cancel()
        }
    }
    
    private func setupAudioPlayer() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(data: data, fileTypeHint: AVFileType.m4a.rawValue)
            player?.prepareToPlay()
            duration = player?.duration ?? 0
        } catch {
            print("Failed to initialize audio player: \(error)")
        }
    }
    
    private func togglePlayback() {
        guard let player = player else { return }
        
        if player.isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }
    
    private func seekForward() {
        guard let player = player else { return }
        player.currentTime = min(player.duration, player.currentTime + 10)
    }
    
    private func seekBackward() {
        guard let player = player else { return }
        player.currentTime = max(0, player.currentTime - 10)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    if let url = Bundle.main.url(forResource: "sample", withExtension: "m4a"),
       let data = try? Data(contentsOf: url) {
        AudioPreview(data: data)
            .frame(width: 300, height: 200)
    } else {
        Text("Sample audio not found")
            .frame(width: 300, height: 200)
    }
}
