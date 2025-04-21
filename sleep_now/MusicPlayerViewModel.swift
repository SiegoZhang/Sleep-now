import SwiftUI

class MusicPlayerViewModel: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentTrack: MusicTrack?
    @Published var isUserPlaying: Bool = false // Track if user is manually playing music
    
    static let shared = MusicPlayerViewModel()
    
    init() {
        // Default track for demo
        currentTrack = MusicTrack(id: 1, title: "Forest", artist: "Sleep Sounds", coverImage: "leaf")
    }
    
    func togglePlayPause() {
        isPlaying.toggle()
        if isPlaying {
            isUserPlaying = true
        }
    }
    
    func playTrack(_ track: MusicTrack) {
        currentTrack = track
        isPlaying = true
        isUserPlaying = true
    }
    
    // Method for sleep mode to play music without marking as user-initiated
    func playSleepMusicIfNotUserPlaying(_ track: MusicTrack) {
        // Only play the sleep music if user isn't already playing music
        if !isUserPlaying || !isPlaying {
            // Wrap state updates in DispatchQueue.main.async to avoid runtime warning
            DispatchQueue.main.async {
                self.currentTrack = track 
                self.isPlaying = true
                self.isUserPlaying = false
            }
        }
    }
    
    // Reset user playing state when stopping
    func stopPlayback() {
        isPlaying = false
        isUserPlaying = false
    }
}

struct MusicTrack: Identifiable, Equatable, Codable {
    let id: Int
    let title: String
    let artist: String
    let coverImage: String
    
    static func == (lhs: MusicTrack, rhs: MusicTrack) -> Bool {
        return lhs.id == rhs.id
    }
} 